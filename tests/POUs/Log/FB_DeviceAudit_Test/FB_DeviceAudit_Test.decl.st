// Назначение: набор coUnit для FB_DeviceAudit — первый вызов без событий, смена режима устройства — событие
//             101018 со значением dev_no · 10 + режим, без журнала — без ошибок. Устройства — PL.FB_DigitalInput,
//             журнал — FB_EventLog (VAR_INST), время — PL.FB_FakeTime.
// Автор:      kr0nsch
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, разделы 9.3, 14.1
FUNCTION_BLOCK FB_DeviceAudit_Test EXTENDS coUnit.FB_TestSuite
VAR CONSTANT
    R_EPS : REAL := 1.0E-6;         // допуск значения события
END_VAR
