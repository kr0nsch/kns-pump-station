// Назначение: набор тестов coUnit для F_StationCfgCheck — проверка уставок станции (04 §18.3): умолчания,
//             по тесту на каждый бит STN_CFG_* с границами, неконечные значения.
// Автор:      kr0nsch
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, раздел 6.13; docs/04_algorithms.md, раздел 18
FUNCTION_BLOCK FB_F_StationCfgCheck_Test EXTENDS coUnit.FB_TestSuite
