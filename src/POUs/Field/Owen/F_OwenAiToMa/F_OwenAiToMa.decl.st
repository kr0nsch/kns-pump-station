// Назначение: встроенный аналоговый вход ОВЕН ПЛК210 → ток для PL.FB_AnalogInput. Канал настроен на тип
//             датчика «4-20 mA» с границами по умолчанию 0 и 100: «Значение» — % диапазона, 0…100 % →
//             4…20 мА. Статус канала не NO_ERROR (обрыв, КЗ, нет данных) — NaN: PL.FB_AnalogInput считает
//             его недостоверным, как и ток вне 3,6…21 мА (NE 43). Сборка targets/plc210.
// Автор:      kr0nsch
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, раздел 8.4; targets/plc210/README.md
FUNCTION F_OwenAiToMa : REAL
VAR_INPUT
    rValue_pct : REAL;      // «Значение» канала, % диапазона 4–20 мА
    usiStatus  : USINT;     // «Статус» канала (PLC210AISTATUS): 0 — NO_ERROR, 240…255 — коды ошибок
END_VAR
VAR
    uBits : PL.U_RealBits;  // NaN из битов
END_VAR
