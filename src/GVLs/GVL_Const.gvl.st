// Назначение: константы проекта. В логике нет «магических чисел» — только имена отсюда.
//             Один файл, три раздела с владельцами (docs/DESIGN.md, раздел 2): «Инфраструктура» —
//             К3, «Станция» — К1, «Модель» — К2. Добавлять — только в свой раздел.
// Автор:      <ИМЯ ФАМИЛИЯ>
// Версия:     0.2.0
// Документ:   docs/DESIGN.md, раздел 2
{attribute 'qualified_only'}
VAR_GLOBAL CONSTANT
    // ===== Инфраструктура (К3) =====
    LOG_CAPACITY : UINT := 200;              // записей в кольце журнала (спецификация 02)
    LOG_VIEW_ROWS : UINT := 20;              // строк на странице журнала HMI
    LOG_FEED_ROWS : UINT := 32;              // строк курсора журнала для внешних клиентов (сценарии ПМИ, SCADA)
    ALM_VIEW_ROWS : UINT := 50;              // строк списка активных тревог
    ALM_SOURCE_MAX : UINT := 40;             // источников тревог: устройства + LIC101 + станция (с запасом)
    ALM_VIEW_PERIOD : TIME := T#500MS;       // обновление списка тревог
    ALM_PRIO_COUNT : UINT := 4;              // приоритеты Low…Critical (индексы auiUnack)
    TAG_LEN : INT := 24;                     // длина тега (как max_device_length iolistgen)
    LOG_CODE_LEN : INT := 32;                // длина кода в CSV
    LOG_CSV_FILE : STRING := 'kns_events.csv';
    LOG_CSV_LINES_PER_WRITE : UINT := 10;    // строк за одну операцию FILE.Write
    VFD_FREQ_NOM_HZ : REAL := 50.0;          // 100 % задания
    VFD_COUNTS_PER_PCT : REAL := 50.0;       // 0,01 Гц: 5000 отсчётов = 100 %
    VFD_STW_READY : WORD := 16#0001;         // условная карта ПЧ (ARCHITECTURE, раздел 12)
    VFD_STW_RUNNING : WORD := 16#0002;
    VFD_STW_FAULT : WORD := 16#0004;
    VFD_STW_WARNING : WORD := 16#0008;
    VFD_STW_REMOTE : WORD := 16#0010;
    VFD_CTW_RESET : WORD := 16#0004;         // сброс аварии по фронту
    // журнал: часы и CSV (DESIGN, разделы 9.1, 9.2)
    LOG_RTC_OK : UDINT := 0;                 // SysTimeRtcHighResGet: «нет ошибки» (ERR_OK)
    LOG_UTC_MIN_MS : ULINT := 1577836800000; // 2020-01-01T00:00:00Z: раньше — часы ПЛК не выставлены
    LOG_CSV_LINE_LEN : INT := 160;           // длина строки CSV с CRLF (ASCII), с запасом
    LOG_CSV_TIMEOUT_US : UDINT := 1000000;   // таймаут FILE.Write, мкс (CAA File)
    LOG_DEV_MODE_SCALE : UINT := 10;         // событие 101018: значение dev_no · 10 + режим (04 §16)
    ALM_SLOT_MAX : UINT := 7;                // последний слот тревог источника (PL.GVL_Const.DEV_ALARMS_MAX - 1)
    LOG_NUM_LEN : INT := 10;                 // знаков в десятичной записи UDINT
    LOG_ISO_LEN : INT := 24;                 // «2026-10-16T07:41:05.120Z»
    LOG_SUFFIX_LEN : INT := 8;               // суффикс кода тревоги и короткие поля CSV
    LOG_PATH_LEN : INT := 255;               // путь файла CAA File
    LOG_CSV_BUF_LEN : UDINT := 1760;         // буфер FILE.Write: (LOG_CSV_LINES_PER_WRITE + 1) · LOG_CSV_LINE_LEN
    // заголовок CSV журнала (DESIGN, раздел 9.2)
    LOG_CSV_HEADER : STRING := 'seq;time_utc;kind;id;code;priority;old_state;new_state;reason;value$R$N';
END_VAR
