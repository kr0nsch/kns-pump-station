"""Исполнитель сценариев через OPC UA-сервер рантайма CODESYS (asyncua, синхронный API; DESIGN, раздел 14.3).

Адрес переменной — ``ns=<индекс>;s=|var|<устройство>.Application.<путь>``: индекс — по URI пространства
имён, оканчивающемуся на ``IecVarAccess``, имя устройства — обзором ``Objects/DeviceSet`` (константой не
задаются: у ПЛК210 они другие). Вход — политика Basic256Sha256 (Sign&Encrypt), имя и пароль из
``credentials.json``; сертификат клиента создаётся при первом запуске в ``~/.local/plc-tools/opcua-client/``
(вне репозитория). Без сертификата сервера CODESYS даёт только конечную точку ``None`` без способов входа
(зонд Z5 архитектуры): нужен ручной шаг 5 DESIGN, раздел 16. Режим ``security="none"`` — для тестов на
сервере asyncua в процессе.

Сброс приложения (шаг ``reset``) OPC UA не умеет: его выполняет ``resetter`` — скрипт CODESYS
(``tools_project/codesys/sim.py reset warm|cold``), после чего клиент открывает новый сеанс.

Запись — ``DataValue(Variant(значение, тип))`` без меток времени, тип — по текущему значению узла (кэш; у
перечислений ``DataType`` — тип перечисления, а значение — базового типа): CODESYS не принимает значение не того
типа и метки времени источника.
"""

from __future__ import annotations

import ipaddress
import socket
from collections.abc import Callable, Mapping, Sequence
from pathlib import Path
from types import TracebackType
from typing import Any, Literal

from asyncua import ua
from asyncua.crypto import cert_gen
from asyncua.sync import Client, SyncNode
from cryptography import x509
from cryptography.hazmat.primitives.serialization import Encoding
from cryptography.x509.oid import ExtendedKeyUsageOID

from kns_scenarios.client import NotSupportedError, ResetKind
from kns_scenarios.credentials import Credentials
from kns_scenarios.values import PlcValue

DEFAULT_URL = "opc.tcp://localhost:4840"
IEC_NAMESPACE_SUFFIX = "IecVarAccess"
DEVICE_SET = "DeviceSet"
APPLICATION = "Application"
CLIENT_CERT_DIR = Path("~/.local/plc-tools/opcua-client")
CLIENT_APP_URI = "urn:kns-pump-station:scenarios"
CLIENT_NAME = "kns-pump-station scenarios"
CERT_DAYS = 365
# Предел узлов в одном запросе Read/Write: OPC UA-сервер CODESYS 3.5.17 — 100 (ServerCapabilities/OperationLimits
# MaxNodesPerRead, MaxNodesPerWrite), больший запрос отклоняется с BadTooManyOperations
DEFAULT_MAX_NODES = 100
# Узлы DeviceSet, которые не являются устройством ПЛК
_NOT_DEVICES = frozenset({"DeviceFeatures"})
_INT_TYPES = frozenset(
    {
        ua.VariantType.SByte,
        ua.VariantType.Byte,
        ua.VariantType.Int16,
        ua.VariantType.UInt16,
        ua.VariantType.Int32,
        ua.VariantType.UInt32,
        ua.VariantType.Int64,
        ua.VariantType.UInt64,
    }
)
_REAL_TYPES = frozenset({ua.VariantType.Float, ua.VariantType.Double})

Security = Literal["none", "Basic256Sha256"]


class OpcUaError(Exception):
    """Сервер не тот, что ожидается: нет пространства имён CODESYS, устройства, неподдерживаемое значение."""


def find_iec_namespace(namespaces: Sequence[str]) -> int:
    """Индекс пространства имён переменных МЭК (URI оканчивается на ``IecVarAccess``)."""
    for index, uri in enumerate(namespaces):
        if uri.endswith(IEC_NAMESPACE_SUFFIX):
            return index
    raise OpcUaError(f"нет пространства имён *{IEC_NAMESPACE_SUFFIX} — это не OPC UA-сервер CODESYS?")


def node_id(namespace: int, device: str, path: str) -> str:
    """Строковый узел CODESYS: ``ns=4;s=|var|CODESYS Control Win V3.Application.GVL_IO.xLS102``."""
    return f"ns={namespace};s=|var|{device}.{APPLICATION}.{path}"


def ensure_client_certificate(cert_dir: Path, app_uri: str = CLIENT_APP_URI) -> tuple[Path, Path]:
    """Сертификат (DER) и ключ (PEM) клиента; нет — создаются (самоподписанный, CERT_DAYS дней)."""
    cert_dir.mkdir(parents=True, exist_ok=True)
    cert, key = cert_dir / "client_cert.der", cert_dir / "client_key.pem"
    if cert.is_file() and key.is_file():
        return cert, key
    host = socket.gethostname()
    private_key = cert_gen.generate_private_key()
    certificate = cert_gen.generate_self_signed_app_certificate(
        private_key,
        CLIENT_NAME,
        {},
        [
            x509.UniformResourceIdentifier(app_uri),
            x509.DNSName(host),
            x509.IPAddress(ipaddress.ip_address("127.0.0.1")),
        ],
        [ExtendedKeyUsageOID.CLIENT_AUTH],
        days=CERT_DAYS,
    )
    key.write_bytes(cert_gen.dump_private_key_as_pem(private_key))
    cert.write_bytes(certificate.public_bytes(Encoding.DER))
    return cert, key


def read_operation_limits(client: Client) -> tuple[int, int]:
    """Пределы узлов в запросе Read и Write сервера (0 или нет узла — ``DEFAULT_MAX_NODES``)."""
    limits = []
    for name in ("MaxNodesPerRead", "MaxNodesPerWrite"):
        try:
            node = client.nodes.server.get_child(["0:ServerCapabilities", "0:OperationLimits", f"0:{name}"])
            value = int(node.read_value())
        except Exception:  # сервер без OperationLimits (имитатор в тестах)
            value = 0
        limits.append(value if value > 0 else DEFAULT_MAX_NODES)
    return limits[0], limits[1]


def variant_type_of(node: SyncNode) -> ua.VariantType:
    """Тип значения для записи — по текущему значению узла: у перечисления CODESYS ``DataType`` — свой тип
    перечисления (``read_data_type_as_variant_type`` даёт Int32), а значение передаётся базовым типом
    (``E_RotationMode`` … ``INT`` — Int16); запись не того типа сервер отклоняет с ``BadTypeMismatch``."""
    value = node.read_data_value().Value
    if value is not None and value.VariantType not in (ua.VariantType.Null, ua.VariantType.Variant):
        current: ua.VariantType = value.VariantType
        return current
    declared: ua.VariantType = node.read_data_type_as_variant_type()
    return declared


def chunks(items: Sequence[Any], size: int) -> list[Sequence[Any]]:
    """Части списка не длиннее ``size`` (пакет больше предела сервера — несколько запросов по порядку)."""
    return [items[i : i + size] for i in range(0, len(items), max(size, 1))]


def discover_device(objects: SyncNode) -> str:
    """Имя устройства ПЛК — первый узел ``Objects/DeviceSet``, кроме служебных."""
    for child in objects.get_children():
        if child.read_browse_name().Name != DEVICE_SET:
            continue
        for device in child.get_children():
            name = str(device.read_browse_name().Name)
            if name not in _NOT_DEVICES:
                return name
    raise OpcUaError(f"нет устройства в Objects/{DEVICE_SET}")


def _from_ua(path: str, value: Any) -> PlcValue:
    if isinstance(value, bool | int | float | str):
        return value
    raise OpcUaError(f"{path}: значение типа {type(value).__name__} не поддержано (только скаляры)")


def _to_variant(path: str, value: PlcValue, vtype: ua.VariantType) -> ua.Variant:
    if vtype == ua.VariantType.Boolean:
        return ua.Variant(bool(value), vtype)
    if vtype in _INT_TYPES:
        if isinstance(value, str) or (isinstance(value, float) and not value.is_integer()):
            raise OpcUaError(f"{path}: {value!r} — нужно целое ({vtype.name})")
        return ua.Variant(int(value), vtype)
    if vtype in _REAL_TYPES:
        if isinstance(value, str):
            raise OpcUaError(f"{path}: {value!r} — нужно число ({vtype.name})")
        return ua.Variant(float(value), vtype)
    if vtype == ua.VariantType.String:
        return ua.Variant(str(value), vtype)
    raise OpcUaError(f"{path}: тип узла {vtype.name} не поддержан")


class OpcUaClient:
    """``PlcClient`` поверх asyncua: пакетное чтение и запись путей GVL."""

    def __init__(
        self,
        url: str = DEFAULT_URL,
        *,
        credentials: Credentials | None = None,
        security: Security = "Basic256Sha256",
        cert_dir: Path | None = None,
        device: str | None = None,
        timeout_s: float = 4.0,
        resetter: Callable[[ResetKind], None] | None = None,
    ) -> None:
        self.url = url
        self.credentials = credentials
        self.security: Security = security
        self.cert_dir = (cert_dir or CLIENT_CERT_DIR).expanduser()
        self.device = device
        self.timeout_s = timeout_s
        self.resetter = resetter
        self.namespace = -1
        self._client: Client | None = None
        self._types: dict[str, ua.VariantType] = {}
        self.max_read = DEFAULT_MAX_NODES
        self.max_write = DEFAULT_MAX_NODES

    # --- соединение ---------------------------------------------------------------------------

    def connect(self) -> OpcUaClient:
        client = Client(self.url, timeout=self.timeout_s)
        client.application_uri = CLIENT_APP_URI
        if self.credentials is not None:
            client.set_user(self.credentials.user)
            client.set_password(self.credentials.password)
        if self.security == "Basic256Sha256":
            cert, key = ensure_client_certificate(self.cert_dir)
            client.set_security_string(f"Basic256Sha256,SignAndEncrypt,{cert},{key}")
        client.connect()
        self._client = client
        try:
            self.namespace = find_iec_namespace(client.get_namespace_array())
            if self.device is None:
                self.device = discover_device(client.nodes.objects)
            self.max_read, self.max_write = read_operation_limits(client)
        except Exception:
            self.close()
            raise
        return self

    @property
    def client(self) -> Client:
        if self._client is None:
            raise OpcUaError("нет соединения: сначала connect()")
        return self._client

    def close(self) -> None:
        if self._client is not None:
            try:
                self._client.disconnect()
            finally:
                self._client = None

    def __enter__(self) -> OpcUaClient:
        return self.connect() if self._client is None else self

    def __exit__(
        self, exc_type: type[BaseException] | None, exc: BaseException | None, tb: TracebackType | None
    ) -> None:
        self.close()

    # --- PlcClient ----------------------------------------------------------------------------

    def node(self, path: str) -> SyncNode:
        if self.device is None:
            raise OpcUaError("имя устройства не определено: сначала connect()")
        return self.client.get_node(node_id(self.namespace, self.device, path))

    def read(self, paths: Sequence[str]) -> list[PlcValue]:
        if not paths:
            return []
        values: list[Any] = []
        for part in chunks(list(paths), self.max_read):
            values += self.client.read_values([self.node(p) for p in part])
        return [_from_ua(p, v) for p, v in zip(paths, values, strict=True)]

    def write(self, values: Mapping[str, PlcValue]) -> None:
        if not values:
            return
        nodes = [self.node(p) for p in values]
        for path, node in zip(values, nodes, strict=True):
            if path not in self._types:
                self._types[path] = variant_type_of(node)
        data = [ua.DataValue(_to_variant(p, v, self._types[p])) for p, v in values.items()]
        for start in range(0, len(nodes), max(self.max_write, 1)):
            self.client.write_values(nodes[start : start + self.max_write], data[start : start + self.max_write])

    def reconnect(self) -> None:
        """Новый сеанс (после сброса приложения узлы и типы перечитываются)."""
        self.close()
        self._types.clear()
        self.connect()

    def reset(self, kind: ResetKind) -> None:
        """Сброс приложения через ``resetter`` (скрипт CODESYS ``tools_project/codesys/sim.py reset``) и новый
        сеанс; без него OPC UA сбросить приложение не может — ``NotSupportedError``."""
        if self.resetter is None:
            raise NotSupportedError(
                f"сброс «{kind}»: у исполнителя opcua нет средства сброса (sim.py reset) — только исполнитель cds"
            )
        self.resetter(kind)
        self.reconnect()
