// Назначение: полевая шина сборки ОВЕН ПЛК210, выход (MainTask, последней — после PRG_FieldOut): слово
//             управления и задание частоты ПЧ Н1…Н3 → каналы записи Modbus RTU (FC16 4x 0…1). Встроенные
//             релейные выходы DO5…DO11 привязаны к GVL_IO в дереве устройств напрямую. Массивы привязывает
//             к каналам tools_project/codesys/plc210_io.py.
// Автор:      kr0nsch
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, раздел 8.4; targets/plc210/README.md
PROGRAM PRG_FieldBusOut_Plc210
VAR
    awP101Wr : ARRAY[0..GVL_ConstPlc210.MB_VFD_WR_LAST] OF WORD;     // слейв 1: FC16 4x 0…1
    awP102Wr : ARRAY[0..GVL_ConstPlc210.MB_VFD_WR_LAST] OF WORD;     // слейв 2
    awP103Wr : ARRAY[0..GVL_ConstPlc210.MB_VFD_WR_LAST] OF WORD;     // слейв 3
END_VAR
