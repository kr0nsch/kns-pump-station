// Назначение: набор coUnit для FB_StormGenerator и F_Xorshift32 — ливни по seed: известные значения
//             xorshift32, ливни суток для seed по умолчанию, детерминизм и независимость от шага вызова,
//             трапеция, переход через полночь, снятие ливней, предел числа, нулевое состояние генератора.
//             Ожидаемые значения — эталон tools_project/plant_reference.py (сценарии xorshift.*, storms.*).
// Автор:      kr0nsch
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, разделы 11.3, 14.1
FUNCTION_BLOCK FB_StormGenerator_Test EXTENDS coUnit.FB_TestSuite
VAR CONSTANT
    R_EPS_H : REAL := 1.0E-4;         // допуск начала ливня, ч (REAL против float64 эталона)
    R_EPS_M3H : REAL := 1.0E-3;       // допуск притока и пика, м³/ч
    UI_MAX_TOO_MANY : UINT := 10;     // больше SIM_STORMS_MAX
    UI_STEPS : UINT := 50;            // шагов часов в проверке независимости от шага
END_VAR
