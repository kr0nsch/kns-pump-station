// Назначение: экземпляры наборов тестов команды К3 (сгенерированный слой, полевой слой, журнал, сводка тревог).
//             Объявление регистрирует набор в coUnit; {attribute 'linkalways'} обязателен — без него
//             компилятор выбросит GVL, на которую никто не ссылается, и наборы молча пропадут.
// Автор:      kr0nsch
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, раздел 14.1
{attribute 'qualified_only'}
{attribute 'linkalways'}
VAR_GLOBAL
    fbVfdAdapterCondTest : FB_VfdAdapter_Cond_Test;   // 8.2
    fbEventLogTest       : FB_EventLog_Test;          // 9.1
    fbEventLogCsvTest    : FB_EventLogCsv_Test;       // 9.2 (многоцикловые, CAA File)
    fbUtcToIsoTest       : FB_F_UtcToIso_Test;        // 9.2
    fbAlarmCodeTest      : FB_F_AlarmCode_Test;       // 9.2
    fbAlarmSummaryTest   : FB_AlarmSummary_Test;      // 9.3
    fbDeviceAuditTest    : FB_DeviceAudit_Test;       // 9.3
    fbPlcStartAdoptionTest : FB_PlcStartAdoption_Test;  // 4.6, 7: подхват насоса в порядке PRG_Devices
END_VAR
