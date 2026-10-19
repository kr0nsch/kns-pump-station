// Назначение: набор coUnit для FB_InflowProfile — суточный профиль притока: значения в точках и между
//             ними, переход через полночь, среднее за сутки, неконечные входы. Ожидаемые значения — эталон
//             tools_project/plant_reference.py, сценарий inflow.profile (профиль ST_SimCfg по умолчанию).
// Автор:      <ИМЯ ФАМИЛИЯ>
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, разделы 11.3, 14.1
FUNCTION_BLOCK FB_InflowProfile_Test EXTENDS coUnit.FB_TestSuite
VAR CONSTANT
    R_AVG_M3H : REAL := 70.0;         // stSimCfg.rInflowAvg_m3h по умолчанию
    R_EPS : REAL := 1.0E-4;           // допуск REAL для значений порядка 100
    UI_SAMPLES : UINT := 96;          // отсчётов за сутки (через 15 мин)
    R_SAMPLE_H : REAL := 0.25;
    DW_NAN : DWORD := 16#7FC00000;
END_VAR
