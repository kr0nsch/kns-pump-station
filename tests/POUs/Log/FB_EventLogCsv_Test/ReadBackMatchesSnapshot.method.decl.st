// Выгрузка 12 записей, затем файл читается назад (FILE.Open MREAD, Read, Close): длина и байты совпадают с
// заголовком и строками F_EventCsvLine снимка
METHOD PRIVATE ReadBackMatchesSnapshot
VAR_INST
    fbLog     : FB_EventLog;        // журнал со снимком
    fbCsv     : FB_EventLogCsv;     // проверяемая выгрузка
    fbOpen    : FILE.Open;          // чтение назад
    fbRead    : FILE.Read;
    fbClose   : FILE.Close;
    abRead    : ARRAY[0..READ_BUF_LEN - 1] OF BYTE;   // прочитанный файл
    abExp     : ARRAY[0..READ_BUF_LEN - 1] OF BYTE;   // ожидаемое содержимое
    udiExpLen : UDINT;              // байт ожидаемого содержимого
    udiReadLen : UDINT;             // байт прочитано
    uiPolls  : UINT;               // вызовов теста с начала
    iStep     : INT;                // 0 — запись, 1 — открыть, 2 — читать, 3 — закрыть, 4 — сравнить
    xReadError : BOOL;              // ошибка CAA File при чтении назад
END_VAR
VAR
    fbTime  : PL.FB_FakeTime;       // подменное время
    stRec   : ST_EventRecord;       // запись снимка
    uiI     : UINT;                 // номер записи
    udiDiff : UDINT;                // байт, отличных от ожидаемых
    udiK    : UDINT;                // номер байта
END_VAR
