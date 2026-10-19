"""PLCopenXML объекта Persistent Variables, которым импорт создаёт *.pvl.st (import_sources.persistent_vars_xml)."""

from __future__ import annotations

import importlib
import xml.etree.ElementTree as ET
from typing import Any

NS = {
    "tc6": "http://www.plcopen.org/xml/tc6_0200",
    "xhtml": "http://www.w3.org/1999/xhtml",
}
DECL = (
    "// шапка: <имя> & «кавычки»\n"
    "VAR_GLOBAL PERSISTENT RETAIN\n"
    "    stCfg : ST_Cfg := (rX := 1.0, sName := 'a\"b');  // x < y\n"
    "END_VAR\n"
)


def module() -> Any:
    # import_sources — скрипт CODESYS (IronPython 2.7); без CODESYS импортируется, mypy его не проверяет
    return importlib.import_module("import_sources")


def test_xml_carries_declaration_text_unchanged() -> None:
    text = module().persistent_vars_xml("GVL_Persist", DECL)
    root = ET.fromstring(text.encode("utf-8"))
    gvars = root.find("tc6:addData/tc6:data/tc6:globalVars", NS)
    assert gvars is not None
    assert gvars.get("name") == "GVL_Persist"
    assert (gvars.get("persistent"), gvars.get("retain")) == ("true", "true")
    xhtml = gvars.find("tc6:addData/tc6:data/tc6:InterfaceAsPlainText/xhtml:xhtml", NS)
    assert xhtml is not None
    assert xhtml.text == DECL


def test_xml_is_deterministic_and_lf_only() -> None:
    first = module().persistent_vars_xml("GVL_Persist", DECL)
    assert first == module().persistent_vars_xml("GVL_Persist", DECL)
    assert "\r" not in first
    assert first.endswith("</project>\n")


def test_name_is_escaped_in_attributes() -> None:
    text = module().persistent_vars_xml('A"<B>&', "VAR_GLOBAL PERSISTENT\nEND_VAR\n")
    root = ET.fromstring(text.encode("utf-8"))
    header = root.find("tc6:contentHeader", NS)
    assert header is not None and header.get("name") == 'A"<B>&'
