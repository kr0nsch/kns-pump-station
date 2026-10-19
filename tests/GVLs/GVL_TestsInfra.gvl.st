// Назначение: экземпляры наборов тестов команды К3 (сгенерированный слой, полевой слой, журнал, сводка тревог).
//             Объявление регистрирует набор в coUnit; {attribute 'linkalways'} обязателен — без него
//             компилятор выбросит GVL, на которую никто не ссылается, и наборы молча пропадут.
// Автор:      <ИМЯ ФАМИЛИЯ>
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, раздел 14.1
{attribute 'qualified_only'}
{attribute 'linkalways'}
VAR_GLOBAL
    fbVfdAdapterCondTest : FB_VfdAdapter_Cond_Test;   // 8.2
    fbEventLogTest       : FB_EventLog_Test;          // 9.1
    fbAlarmSummaryTest   : FB_AlarmSummary_Test;      // 9.3
    fbDeviceAuditTest    : FB_DeviceAudit_Test;       // 9.3
END_VAR
