// Назначение: набор coUnit для FB_TankModel — баланс объёма резервуара: интегрирование притока и откачки,
//             перелив и его время, осушенный приёмок, шаг 0 и «время назад», установка уровня. Ожидаемые значения —
//             эталон tools_project/plant_reference.py (сценарии tank.*): dh = (Qin − Qout)·dt / 3600 / S.
// Автор:      <ИМЯ ФАМИЛИЯ>
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, разделы 11.3, 14.1
FUNCTION_BLOCK FB_TankModel_Test EXTENDS coUnit.FB_TestSuite
VAR CONSTANT
    R_AREA_M2 : REAL := 12.0;
    R_OVERFLOW_M : REAL := 4.6;
    LR_STEP_S : LREAL := 10.0;        // шаг интегрирования в тесте
    LR_SHORT_S : LREAL := 0.2;        // шаг SIM_DT_SUBSTEP
    UI_STEPS_1H : UINT := 360;        // 1 ч шагами по 10 с
    UI_STEPS_10MIN : UINT := 60;
    R_EPS_M : REAL := 1.0E-5;
END_VAR
