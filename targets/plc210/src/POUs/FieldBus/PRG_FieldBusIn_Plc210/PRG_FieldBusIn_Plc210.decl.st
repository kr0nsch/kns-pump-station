// Назначение: полевая шина сборки ОВЕН ПЛК210, вход (MainTask, первой): встроенные AI ПЛК210-14 и вход 1
//             модуля МВ210-101 (Modbus TCP) → токи GVL_IO.r*_mA; регистры ПЧ Н1…Н3 (Modbus RTU, RS485-1) и
//             TT403 (RS485-2) → GVL_IO; признаки обмена GVL_IO.xMbOk_* — по диагностике слейвов Modbus
//             (выход xError экземпляра слейва в дереве устройств). Встроенные DI и модуль МВ210-202 привязаны
//             к GVL_IO в дереве устройств напрямую, кода для них нет. Массивы ниже привязывает к каналам
//             tools_project/codesys/plc210_io.py.
// Автор:      kr0nsch
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, раздел 8.4; targets/plc210/README.md
PROGRAM PRG_FieldBusIn_Plc210
VAR
    // встроенные AI: «Значение» (% диапазона 4–20 мА) и «Статус» каналов правой платы
    arAiValue_pct : ARRAY[GVL_ConstPlc210.AI_FIRST..GVL_ConstPlc210.AI_LAST] OF REAL;
    ausiAiStatus : ARRAY[GVL_ConstPlc210.AI_FIRST..GVL_ConstPlc210.AI_LAST] OF USINT;
    awMx101Ai1 : ARRAY[0..GVL_ConstPlc210.MB_PAIR_LAST] OF WORD;     // МВ210-101: регистры 4000…4001
    awP101Rd : ARRAY[0..GVL_ConstPlc210.MB_VFD_RD_LAST] OF WORD;     // слейв 1: FC3 4x 100…103
    awP102Rd : ARRAY[0..GVL_ConstPlc210.MB_VFD_RD_LAST] OF WORD;     // слейв 2
    awP103Rd : ARRAY[0..GVL_ConstPlc210.MB_VFD_RD_LAST] OF WORD;     // слейв 3
    awTT403Rd : ARRAY[0..GVL_ConstPlc210.MB_PAIR_LAST] OF WORD;      // RS485-2, слейв 10: FC4 3x 0…1
    rAT402_mA : REAL;                                                 // A1.5 до проверки связи с модулем
    uNan : PL.U_RealBits;                                             // NaN: нет связи с МВ210-101
END_VAR
