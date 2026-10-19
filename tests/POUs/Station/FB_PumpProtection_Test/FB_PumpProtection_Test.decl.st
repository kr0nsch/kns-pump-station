// Назначение: набор тестов coUnit для FB_PumpProtection — недогрузка по току с фиксацией до сброса и
//             перегрев обмотки (04 §10.3, 10.4): выдержка, границы частоты и тока, недостоверный и
//             неконечный ток, сброс, выключение порогом 0.
// Автор:      kr0nsch
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, раздел 6.8; docs/04_algorithms.md, разделы 10.3, 10.4
FUNCTION_BLOCK FB_PumpProtection_Test EXTENDS coUnit.FB_TestSuite
