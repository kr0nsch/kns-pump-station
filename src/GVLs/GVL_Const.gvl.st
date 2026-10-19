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
    // ===== Станция (К1) =====
    STN_PUMP_COUNT : UINT := 3;
    STN_DUTY_MAX : UINT := 2;                // «два рабочих + один резервный», предел uiDutyMax
    STN_ALARM_COUNT : UINT := 13;            // 04 §15
    STN_ALARM_ID_BASE : UDINT := 100000;     // номер = база + slot (API 20.5)
    STN_EVENT_ID_BASE : UDINT := 101000;     // номер события = база + код E_StationEvent (04 §16)
    LIC101_ALARM_ID_BASE : UDINT := 100100;  // слот 0 PVF
    KNS_ILK_DRY_RUN : WORD := 16#0001;       // wInterlock насоса, бит 0: сухой ход станции (04 §10.6)
    KNS_ILK_UNDERLOAD : WORD := 16#0002;     // бит 1: недогрузка по току, фиксируется до сброса насоса
    KNS_ILK_OVERHEAT : WORD := 16#0004;      // бит 2: перегрев обмотки, пока сигнал активен
    V1_ILK_FIRE : WORD := 16#0001;           // fbV1.wInterlock, бит 0: пожар (04 §17)
    STN_LS102_MARK_M : REAL := 4.20;         // отметка поплавка (перечень) — для проверки порядка уставок
    STN_LS103_MARK_M : REAL := 0.40;
    STN_PID_RECOVER : TIME := T#30S;         // связь с ПЧ восстановлена → ПИД снова готов (04 §12)
    STN_HANDOVER_RETRY : TIME := T#10M;      // повтор передачи роли (04 §8.2)
    STN_HANDOVER_START_TIMEOUT : TIME := T#30S;  // передача роли: замена не в работе за это время — пуск не удался
    STN_SEQ_START_TIMEOUT : TIME := T#30S;   // шаг последовательного пуска: пуск не подтвердился → следующий
    STN_ATS_WINDOW : TIME := T#10S;          // окно поиска насоса, введённого АВР (событие 101006)
    STN_LAMP_HALF_PERIOD : TIME := T#500MS;  // HL1 мигает 1 Гц
    STN_FULL_SPEED_PCT : REAL := 100.0;      // аварийный режим и по поплавкам
    STN_FLOW_SETTLE : TIME := T#20S;         // насос работает дольше — L/LL PT201, L FT202 не подавляются (условно)
    // биты stStationSts.wState (04 §19.3)
    STN_ST_DRY_RUN : WORD := 16#0001;
    STN_ST_EMERGENCY : WORD := 16#0002;
    STN_ST_FLOAT : WORD := 16#0004;
    STN_ST_STEP_FALLBACK : WORD := 16#0008;
    STN_ST_POWER_LOST : WORD := 16#0010;
    STN_ST_RESTART : WORD := 16#0020;
    STN_ST_ATS : WORD := 16#0040;
    STN_ST_NO_RESERVE : WORD := 16#0080;
    STN_ST_LACK : WORD := 16#0100;
    STN_ST_LS102_MASKED : WORD := 16#0200;
    STN_ST_LS103_MASKED : WORD := 16#0400;
    STN_ST_SIMULATION : WORD := 16#0800;
    STN_ST_HORN : WORD := 16#1000;
    STN_ST_COMMON_ALARM : WORD := 16#2000;   // K1 обесточено
    STN_ST_UNACK : WORD := 16#4000;
    STN_ST_LT_MASKED : WORD := 16#8000;      // LT101 исключён по противоречию с поплавком (04 §10.5)
    // биты stStationSts.wCfgErr (F_StationCfgCheck, 04 §18.3)
    STN_CFG_LEVEL_ORDER : WORD := 16#0001;   // нарушен порядок отметок 04 §1
    STN_CFG_LEVEL_RANGE : WORD := 16#0002;   // уровень вне диапазона 04 §18.2
    STN_CFG_SPEED : WORD := 16#0004;         // rStepSpeed_pct
    STN_CFG_PID_STAGING : WORD := 16#0008;   // rAssistOn_pct, rAssistOff_pct, выдержки
    STN_CFG_DUTY : WORD := 16#0010;          // uiDutyMax
    STN_CFG_ROTATION : WORD := 16#0020;      // eRotation, tMaxContRun, tOverlap, tStagger
    STN_CFG_TIMES : WORD := 16#0040;         // питание, tDryRelease, tLtRecover, tLvlConfirm, tV1Overrun
    STN_CFG_FLOAT_CHECK : WORD := 16#0080;   // rLdev*, tLdev
    STN_CFG_UNDERLOAD : WORD := 16#0100;
    STN_CFG_ALARM : WORD := 16#0200;         // приоритет тревоги вне перечисления
    STN_CFG_SETPOINT : WORD := 16#0400;      // rLevelSp_m вне rSpMin_eu…rSpMax_eu LIC101
    // диапазоны параметров 04 §18.2 (F_StationCfgCheck)
    STN_LVL_STOP_MIN_M : REAL := 0.90;       // № 2
    STN_LVL_STOP_MAX_M : REAL := 2.00;
    STN_LVL_START_LEAD_MAX_M : REAL := 3.00; // № 3
    STN_LVL_START_ASSIST_MAX_M : REAL := 3.30;   // № 5
    STN_LVL_GAP_M : REAL := 0.30;            // зазоры № 3–5: пуск выше останова не меньше чем на 0,3 м
    STN_CFG_EPS : REAL := 0.001;             // допуск сравнения суммы двух уставок REAL (зазоры № 3–5, 11)
    STN_LVL_CONFIRM_MAX : TIME := T#60S;     // № 6
    STN_STEP_SPEED_MIN_PCT : REAL := 60.0;   // № 7 (верх — PL.GVL_Const.PCT_FULL)
    STN_ASSIST_ON_MIN_PCT : REAL := 80.0;    // № 9
    STN_ASSIST_ON_T_MIN : TIME := T#5S;      // № 10
    STN_ASSIST_ON_T_MAX : TIME := T#300S;
    STN_ASSIST_OFF_MIN_PCT : REAL := 60.0;   // № 11
    STN_ASSIST_GAP_PCT : REAL := 10.0;       // № 11: rAssistOff_pct <= rAssistOn_pct - 10
    STN_ASSIST_OFF_T_MIN : TIME := T#10S;    // № 12
    STN_ASSIST_OFF_T_MAX : TIME := T#600S;
    STN_DUTY_MIN : UINT := 1;                // № 13 (верх — STN_PUMP_COUNT)
    STN_MAX_CONT_RUN_MIN : TIME := T#10M;    // № 15 (T#0S — выключено)
    STN_MAX_CONT_RUN_MAX : TIME := T#24H;
    STN_OVERLAP_MAX : TIME := T#60S;         // № 16
    STN_STAGGER_MAX : TIME := T#30S;         // № 17
    STN_PWR_RESTART_MAX : TIME := T#120S;    // № 18
    STN_SEQ_STEP_MIN : TIME := T#5S;         // № 19
    STN_SEQ_STEP_MAX : TIME := T#120S;
    STN_PLC_START_MAX : TIME := T#120S;      // № 20
    STN_DRY_RELEASE_MIN : TIME := T#10S;     // № 21
    STN_DRY_RELEASE_MAX : TIME := T#600S;
    STN_LDEV102_ON_MIN_M : REAL := 2.50;     // № 22
    STN_LDEV102_ON_MAX_M : REAL := 4.10;
    STN_LDEV102_OFF_MIN_M : REAL := 4.25;    // № 23
    STN_LDEV102_OFF_MAX_M : REAL := 4.90;
    STN_LDEV103_ON_MIN_M : REAL := 0.50;     // № 24
    STN_LDEV103_ON_MAX_M : REAL := 1.50;
    STN_LDEV103_OFF_MIN_M : REAL := 0.05;    // № 25
    STN_LDEV103_OFF_MAX_M : REAL := 0.35;
    STN_LDEV_T_MIN : TIME := T#10S;          // № 26
    STN_LDEV_T_MAX : TIME := T#300S;
    STN_LT_RECOVER_MAX : TIME := T#300S;     // № 27
    STN_UNDERLOAD_MAX_A : REAL := 30.0;      // № 28 (0 — выключено)
    STN_UNDERLOAD_SPEED_MIN_PCT : REAL := 60.0;  // № 29
    STN_UNDERLOAD_T_MIN : TIME := T#5S;      // № 30
    STN_UNDERLOAD_T_MAX : TIME := T#120S;
    STN_V1_OVERRUN_MAX : TIME := T#60M;      // № 31
    // событие 101017: номер параметра 04 §18.2 (№ 2–31 по порядку полей ST_StationCfg)
    STN_CFG_PARAM_FIRST : UINT := 2;         // № первого поля ST_StationCfg (rLvlStop_m)
    STN_CFG_PARAM_ALARMS : UINT := 44;       // таблица тревог astAlarm или резерв (после № 43 раздела 18.2)
    STN_CFG_RESERVE_REAL_LAST : UINT := 7;   // верхняя граница ST_StationCfg.arReserve (тест соответствия)
    STN_CFG_RESERVE_SHORT_LAST : UINT := 3;  // верхняя граница atReserve и auiReserve
    // значения событий станции
    STN_EVT_LS102 : REAL := 102.0;           // 101011/101012: поплавок LS102
    STN_EVT_LS103 : REAL := 103.0;           // 101011/101012: поплавок LS103
    STN_EVT_SRC_BUTTON : REAL := 1.0;        // 101016/101023: кнопка шкафа
    STN_EVT_SRC_HMI : REAL := 2.0;           // 101016/101023: команда HMI
    // биты FB_Protections.wLdev (04 §10.5)
    STN_LDEV_LS102_FALSE : WORD := 16#0001;  // LS102 сработал ложно (уровень ниже rLdev102On_m)
    STN_LDEV_LS102_MISSED : WORD := 16#0002; // LS102 не сработал (уровень выше rLdev102Off_m)
    STN_LDEV_LS103_FALSE : WORD := 16#0004;  // LS103 сработал ложно (уровень выше rLdev103On_m)
    STN_LDEV_LS103_MISSED : WORD := 16#0008; // LS103 не сработал (уровень ниже rLdev103Off_m)
    STN_LDEV_LT_MASKED : WORD := 16#0010;    // LT101 исключён по противоречию (вне диапазона)
    STN_MS_PER_S : UDINT := 1000;            // мс в секунде: остаток в целых секундах вверх (uiSeqRemain_s)
END_VAR
