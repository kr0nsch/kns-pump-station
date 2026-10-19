// Назначение: набор тестов coUnit для FB_LevelControlStepped — ступенчатое регулирование (04 §6): пуск и
//             останов ведущего и подпорного с выдержкой tLvlConfirm и границами включительно, волна, вход
//             без рывка, uiDutyMax, недостоверный уровень, время назад.
// Автор:      kr0nsch
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, раздел 6.3; docs/04_algorithms.md, раздел 6
FUNCTION_BLOCK FB_LevelControlStepped_Test EXTENDS coUnit.FB_TestSuite
