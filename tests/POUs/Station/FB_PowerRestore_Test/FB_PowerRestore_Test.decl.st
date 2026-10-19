// Назначение: набор тестов coUnit для FB_PowerRestore — питание и последовательный пуск (04 §13): задержки
//             старта ПЛК и восстановления, шаги по подтверждению и по таймауту, пропадание во время пуска,
//             остаток времени, первый вызов.
// Автор:      kr0nsch
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, раздел 6.9; docs/04_algorithms.md, раздел 13
FUNCTION_BLOCK FB_PowerRestore_Test EXTENDS coUnit.FB_TestSuite
