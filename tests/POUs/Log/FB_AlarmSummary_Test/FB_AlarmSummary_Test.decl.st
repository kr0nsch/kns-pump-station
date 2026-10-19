// Назначение: набор coUnit для FB_AlarmSummary — счётчики по приоритетам, высший неквитированный приоритет,
//             счётчик новых High/Critical, список тревог (порядок групп, предел строк, период пересчёта,
//             «время назад»), квитирование и откладывание по номеру. Источники — FB_TestAlarmSource,
//             время — PL.FB_FakeTime. Сводка и источники — переменные экземпляра метода (VAR_INST).
// Автор:      kr0nsch
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, разделы 9.3, 14.1
FUNCTION_BLOCK FB_AlarmSummary_Test EXTENDS coUnit.FB_TestSuite
