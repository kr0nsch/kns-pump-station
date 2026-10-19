// Пустое имя файла: открытие не удаётся — Error, код FILE.ERROR не 0, строк 0 (несуществующий каталог
// CAA File на Control Win создаёт сам — проверено прогоном)
METHOD PRIVATE ErrorOnBadPathReported
VAR_INST
    fbLog    : FB_EventLog;         // журнал со снимком
    fbCsv    : FB_EventLogCsv;      // проверяемая выгрузка
    uiPolls : UINT;                // вызовов теста с начала
END_VAR
