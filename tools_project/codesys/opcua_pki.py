"""Сертификаты OPC UA-сервера рантайма CODESYS Control Win и доверие клиенту сценариев (DESIGN, раздел 16, шаг 5).

Хранилище сертификатов рантайма 3.5.17 — каталог ``.pki`` рядом с рабочими файлами процесса: ``own/cert``
(сертификаты устройства, DER, имя — SHA-1 сертификата), ``own/key`` (закрытые ключи, DER PKCS#1, имя — SHA-1
SubjectPublicKeyInfo), ``trusted/cert`` (доверенные сертификаты клиентов), ``quarantine`` и ``untrusted``
(отклонённые). Пользовательский процесс рантайма без прав администратора пишет его в виртуальное хранилище UAC
``%LOCALAPPDATA%\\VirtualStore\\<каталог рантайма>\\.pki`` (проверено на 3.5.17.30).

Экран безопасности IDE создаёт сертификат OPC UA-сервера командой рантайму; Scripting API 3.5.17 такой команды
не имеет. Этот модуль делает то же через файлы: самоподписанный сертификат с ``CN = OPCUAServer@<узел>`` (имя
приложения сервера) и ``ApplicationUri`` сервера в SubjectAltName кладётся в ``own``, сертификат клиента
сценариев — в ``trusted/cert``. Рантайм читает хранилище при запуске: после изменений его перезапускают
(``sim.py pki`` делает это сам). Проверено: после перезапуска сервер предлагает конечные точки Basic256Sha256
(Sign, SignAndEncrypt) со входом по имени и паролю, клиент из ``trusted`` входит, неизвестный клиент попадает в
``quarantine`` и получает ``BadSecurityChecksFailed``.
"""

from __future__ import annotations

import datetime as dt
import hashlib
import os
import socket
import warnings
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import quote

from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.x509.oid import ExtendedKeyUsageOID, NameOID

SERVER_CN_PREFIX = "OPCUAServer@"
VENDOR = "3S - Smart Software Solutions GmbH"
DEVICE = "CODESYS Control Win V3"
UNSTRUCTURED_NAME = x509.ObjectIdentifier("1.2.840.113549.1.9.2")
SERVER_CERT_DAYS = 3650
KEY_BITS = 2048
REJECTED_DIRS = ("quarantine", "untrusted")


@dataclass(frozen=True)
class PkiChange:
    """Что изменено в хранилище: создан сертификат сервера, добавлен доверенный клиент (имена файлов)."""

    server_cert: str | None = None
    trusted_client: str | None = None
    removed_rejected: tuple[str, ...] = ()

    @property
    def changed(self) -> bool:
        return self.server_cert is not None or self.trusted_client is not None


def server_application_uri(host: str, vendor: str = VENDOR, device: str = DEVICE) -> str:
    """``ApplicationUri`` OPC UA-сервера CODESYS (так его сообщает GetEndpoints): части кодируются как в URL."""
    return f"urn:{host}:{quote(vendor)}:{quote(device)}:OPCUA:Server"


def pki_candidates(runtime_exe: Path, work_dir: Path, local_appdata: Path | None) -> list[Path]:
    """Возможные каталоги ``.pki`` по порядку предпочтения: виртуальное хранилище UAC, каталог программы, рабочий."""
    out: list[Path] = []
    exe_dir = runtime_exe.parent
    if local_appdata is not None and exe_dir.drive:
        relative = Path(*exe_dir.parts[1:])  # без диска: Program Files (x86)\CODESYS ...\GatewayPLC
        out.append(local_appdata / "VirtualStore" / relative / ".pki")
    out += [exe_dir / ".pki", work_dir / ".pki"]
    return out


def find_pki(candidates: list[Path]) -> Path | None:
    """Первый существующий каталог хранилища (с подкаталогом ``own``)."""
    for path in candidates:
        if (path / "own").is_dir():
            return path
    return None


def _thumbprint(der: bytes) -> str:
    return hashlib.sha1(der).hexdigest()  # имя файла в хранилище CODESYS, не защита


def _key_name(key: rsa.RSAPrivateKey) -> str:
    spki = key.public_key().public_bytes(serialization.Encoding.DER, serialization.PublicFormat.SubjectPublicKeyInfo)
    return hashlib.sha1(spki).hexdigest()  # имя файла в хранилище CODESYS


def server_certificates(pki: Path) -> list[Path]:
    """Сертификаты OPC UA-сервера в ``own/cert`` (``CN`` начинается с ``OPCUAServer@``)."""
    found = []
    for path in sorted((pki / "own" / "cert").glob("*.der")):
        try:
            with warnings.catch_warnings():  # у сертификатов рантайма серийный номер 0 (предупреждение cryptography)
                warnings.simplefilter("ignore")
                cert = x509.load_der_x509_certificate(path.read_bytes())
        except ValueError:
            continue
        names = cert.subject.get_attributes_for_oid(NameOID.COMMON_NAME)
        if any(str(n.value).startswith(SERVER_CN_PREFIX) for n in names):
            found.append(path)
    return found


def make_server_certificate(
    host: str, now: dt.datetime | None = None, days: int = SERVER_CERT_DAYS
) -> tuple[bytes, rsa.RSAPrivateKey]:
    """Самоподписанный сертификат OPC UA-сервера (DER) и ключ: имя и атрибуты — как у сертификатов рантайма."""
    key = rsa.generate_private_key(public_exponent=65537, key_size=KEY_BITS)
    name = x509.Name(
        [
            x509.NameAttribute(NameOID.COMMON_NAME, SERVER_CN_PREFIX + host),
            x509.NameAttribute(UNSTRUCTURED_NAME, "Vendor: " + VENDOR),
            x509.NameAttribute(UNSTRUCTURED_NAME, "Device: " + DEVICE),
        ]
    )
    start = (now or dt.datetime.now(dt.UTC)) - dt.timedelta(days=1)
    ski = x509.SubjectKeyIdentifier.from_public_key(key.public_key())
    usage = x509.KeyUsage(
        digital_signature=True,
        content_commitment=True,
        key_encipherment=True,
        data_encipherment=True,
        key_agreement=False,
        key_cert_sign=False,
        crl_sign=False,
        encipher_only=False,
        decipher_only=False,
    )
    alt = x509.SubjectAlternativeName(
        [x509.UniformResourceIdentifier(server_application_uri(host)), x509.DNSName(host), x509.DNSName("localhost")]
    )
    cert = (
        x509.CertificateBuilder()
        .subject_name(name)
        .issuer_name(name)
        .public_key(key.public_key())
        .serial_number(x509.random_serial_number())
        .not_valid_before(start)
        .not_valid_after(start + dt.timedelta(days=days))
        .add_extension(alt, critical=False)
        .add_extension(x509.BasicConstraints(ca=False, path_length=None), critical=True)
        .add_extension(usage, critical=True)
        .add_extension(x509.ExtendedKeyUsage([ExtendedKeyUsageOID.SERVER_AUTH, ExtendedKeyUsageOID.CLIENT_AUTH]), False)
        .add_extension(ski, critical=False)
        .add_extension(x509.AuthorityKeyIdentifier.from_issuer_subject_key_identifier(ski), critical=False)
        .sign(key, hashes.SHA256())
    )
    return cert.public_bytes(serialization.Encoding.DER), key


def install_server_certificate(pki: Path, host: str) -> str:
    """Записать новый сертификат сервера и ключ в ``own``; возвращает имя файла сертификата."""
    der, key = make_server_certificate(host)
    key_der = key.private_bytes(
        serialization.Encoding.DER, serialization.PrivateFormat.TraditionalOpenSSL, serialization.NoEncryption()
    )
    (pki / "own" / "cert").mkdir(parents=True, exist_ok=True)
    (pki / "own" / "key").mkdir(parents=True, exist_ok=True)
    name = _thumbprint(der) + ".der"
    (pki / "own" / "cert" / name).write_bytes(der)
    (pki / "own" / "key" / (_key_name(key) + ".key")).write_bytes(key_der)
    return name


def trust_client(pki: Path, client_der: bytes) -> tuple[str | None, tuple[str, ...]]:
    """Сертификат клиента — в ``trusted/cert`` (если его там нет), копии в отклонённых удаляются."""
    name = _thumbprint(client_der) + ".der"
    removed = []
    for sub in REJECTED_DIRS:
        for path in (pki / sub).rglob(name) if (pki / sub).is_dir() else ():
            path.unlink()
            removed.append(str(path.relative_to(pki)))
    target = pki / "trusted" / "cert" / name
    if target.is_file() and target.read_bytes() == client_der:
        return None, tuple(removed)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(client_der)
    return name, tuple(removed)


def provision(pki: Path, client_der: bytes, host: str | None = None) -> PkiChange:
    """Сертификат сервера (если нет) и доверие клиенту; идемпотентно."""
    host = host or socket.gethostname()
    server = None if server_certificates(pki) else install_server_certificate(pki, host)
    trusted, removed = trust_client(pki, client_der)
    return PkiChange(server, trusted, removed)


def local_appdata() -> Path | None:
    raw = os.environ.get("LOCALAPPDATA")
    return Path(raw) if raw else None
