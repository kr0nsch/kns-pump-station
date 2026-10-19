// Назначение: набор тестов coUnit для FB_StationMode — режим станции и способ регулирования: санитизация
//             retain, запросы режима насосам при переходах, старшинство команд, импульсы входа, события
//             101001–101004.
// Автор:      kr0nsch
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, раздел 6.1; docs/04_algorithms.md, раздел 3
FUNCTION_BLOCK FB_StationMode_Test EXTENDS coUnit.FB_TestSuite
