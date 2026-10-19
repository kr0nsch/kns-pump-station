"""Сертификаты OPC UA рантайма (opcua_pki.py) и разбор аргументов sim.py — без CODESYS."""

from __future__ import annotations

import datetime as dt
import hashlib
from pathlib import Path

import pytest
from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.x509.oid import ExtendedKeyUsageOID, NameOID

import opcua_pki as P
import sim

HOST = "DESKTOP-FAK1Q95"


def _pki(tmp_path: Path) -> Path:
    pki = tmp_path / ".pki"
    for sub in ("own/cert", "own/key", "trusted/cert", "quarantine", "untrusted"):
        (pki / sub).mkdir(parents=True)
    return pki


def _self_signed(cn: str) -> bytes:
    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    name = x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, cn)])
    now = dt.datetime.now(dt.UTC)
    cert = (
        x509.CertificateBuilder()
        .subject_name(name)
        .issuer_name(name)
        .public_key(key.public_key())
        .serial_number(1)
        .not_valid_before(now)
        .not_valid_after(now + dt.timedelta(days=1))
        .sign(key, hashes.SHA256())
    )
    return cert.public_bytes(serialization.Encoding.DER)


def test_application_uri_matches_codesys_server() -> None:
    # так ApplicationUri сообщает GetEndpoints OPC UA-сервера Control Win V3 3.5.17.30
    assert P.server_application_uri(HOST) == (
        "urn:DESKTOP-FAK1Q95:3S%20-%20Smart%20Software%20Solutions%20GmbH:CODESYS%20Control%20Win%20V3:OPCUA:Server"
    )


def test_server_certificate_fields() -> None:
    der, key = P.make_server_certificate(HOST)
    cert = x509.load_der_x509_certificate(der)
    assert cert.subject.get_attributes_for_oid(NameOID.COMMON_NAME)[0].value == "OPCUAServer@" + HOST
    assert cert.subject == cert.issuer
    alt = cert.extensions.get_extension_for_class(x509.SubjectAlternativeName).value
    assert alt.get_values_for_type(x509.UniformResourceIdentifier) == [P.server_application_uri(HOST)]
    assert HOST in alt.get_values_for_type(x509.DNSName)
    usage = cert.extensions.get_extension_for_class(x509.KeyUsage).value
    assert usage.digital_signature and usage.key_encipherment and usage.data_encipherment
    eku = cert.extensions.get_extension_for_class(x509.ExtendedKeyUsage).value
    assert ExtendedKeyUsageOID.SERVER_AUTH in eku and ExtendedKeyUsageOID.CLIENT_AUTH in eku
    assert isinstance(cert.signature_hash_algorithm, hashes.SHA256)
    assert key.key_size == 2048
    assert cert.not_valid_after_utc - cert.not_valid_before_utc == dt.timedelta(days=P.SERVER_CERT_DAYS)


def test_install_uses_codesys_file_names(tmp_path: Path) -> None:
    pki = _pki(tmp_path)
    name = P.install_server_certificate(pki, HOST)
    der = (pki / "own" / "cert" / name).read_bytes()
    assert name == hashlib.sha1(der).hexdigest() + ".der"
    keys = list((pki / "own" / "key").glob("*.key"))
    assert len(keys) == 1
    key = serialization.load_der_private_key(keys[0].read_bytes(), None)
    spki = key.public_key().public_bytes(serialization.Encoding.DER, serialization.PublicFormat.SubjectPublicKeyInfo)
    assert keys[0].stem == hashlib.sha1(spki).hexdigest()  # имя ключа — SHA-1 SubjectPublicKeyInfo
    cert = x509.load_der_x509_certificate(der)
    assert (
        cert.public_key().public_bytes(serialization.Encoding.DER, serialization.PublicFormat.SubjectPublicKeyInfo)
        == spki
    )


def test_server_certificates_ignores_other_device_certs(tmp_path: Path) -> None:
    pki = _pki(tmp_path)
    other = _self_signed(HOST)  # сертификат шифрованной связи рантайма: CN = имя узла
    (pki / "own" / "cert" / (hashlib.sha1(other).hexdigest() + ".der")).write_bytes(other)
    (pki / "own" / "cert" / "broken.der").write_bytes(b"not a certificate")
    assert P.server_certificates(pki) == []
    P.install_server_certificate(pki, HOST)
    assert len(P.server_certificates(pki)) == 1


def test_trust_client_moves_out_of_quarantine(tmp_path: Path) -> None:
    pki = _pki(tmp_path)
    client = _self_signed("kns-pump-station scenarios")
    name = hashlib.sha1(client).hexdigest() + ".der"
    (pki / "quarantine" / name).write_bytes(client)
    added, removed = P.trust_client(pki, client)
    assert added == name and removed == (str(Path("quarantine") / name),)
    assert (pki / "trusted" / "cert" / name).read_bytes() == client
    assert not (pki / "quarantine" / name).exists()
    assert P.trust_client(pki, client) == (None, ())


def test_provision_is_idempotent(tmp_path: Path) -> None:
    pki = _pki(tmp_path)
    client = _self_signed("client")
    first = P.provision(pki, client, HOST)
    assert first.changed and first.server_cert and first.trusted_client
    second = P.provision(pki, client, HOST)
    assert not second.changed
    assert len(list((pki / "own" / "cert").glob("*.der"))) == 1


def test_pki_candidates_prefer_virtual_store(tmp_path: Path) -> None:
    exe = Path("C:/Program Files (x86)/CODESYS 3.5.17.30/GatewayPLC/CODESYSControlService.exe")
    work = tmp_path / "work"
    local = tmp_path / "Local"
    cands = P.pki_candidates(exe, work, local)
    assert cands[0] == local / "VirtualStore" / "Program Files (x86)" / "CODESYS 3.5.17.30" / "GatewayPLC" / ".pki"
    assert cands[1:] == [exe.parent / ".pki", work / ".pki"]
    assert P.find_pki([tmp_path / "none", work / ".pki"]) is None
    (work / ".pki" / "own").mkdir(parents=True)
    assert P.find_pki(cands) == work / ".pki"


def test_sim_parser() -> None:
    parser = sim.build_parser()
    args = parser.parse_args(["start", "--no-import", "--need-min", "45"])
    assert args.func is sim.cmd_start and args.no_import and args.need_min == 45.0
    assert parser.parse_args(["reset", "cold"]).kind == "cold"
    with pytest.raises(SystemExit):
        parser.parse_args(["reset", "hot"])
    assert parser.parse_args(["pki", "--no-restart"]).no_restart
