// Назначение: набор coUnit для FB_HydraulicSolver и F_PumpCurrent — законы подобия и рабочая точка насосов
//             на общий коллектор: один насос, параллельная работа, разные частоты и обратный клапан, напор ниже
//             статического, сухой ход, засор, осушенный приёмок, ток двигателя, давление PT201. Ожидаемые значения —
//             эталон tools_project/plant_reference.py (сценарии hydraulic.*), характеристика ST_PumpModelCfg по
//             умолчанию; допуски — REAL против float64 эталона.
// Автор:      <ИМЯ ФАМИЛИЯ>
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, разделы 11.3, 14.1
FUNCTION_BLOCK FB_HydraulicSolver_Test EXTENDS coUnit.FB_TestSuite
VAR CONSTANT
    R_LEVEL_M : REAL := 1.4;          // уровень подбора характеристики (DESIGN 11.3)
    R_EPS_Q : REAL := 0.005;          // допуск подачи, м³/ч
    R_EPS_H : REAL := 1.0E-3;         // допуск напора, м
    R_EPS_I : REAL := 1.0E-3;         // допуск тока, А
    R_EPS_P : REAL := 1.0E-4;         // допуск давления, бар
    R_UNDERLOAD_A : REAL := 12.0;     // порог недогрузки rUnderload_A (04 §10.3)
    R_IT_HH_A : REAL := 34.0;         // уставка HH IT1n1 (перечень)
    DW_NAN : DWORD := 16#7FC00000;
END_VAR
