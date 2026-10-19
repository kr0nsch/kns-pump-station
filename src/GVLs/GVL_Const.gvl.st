// Назначение: константы проекта. В логике нет «магических чисел» — только имена отсюда.
//             Один файл, три раздела с владельцами (docs/DESIGN.md, раздел 2): «Инфраструктура» —
//             К3, «Станция» — К1, «Модель» — К2. Добавлять — только в свой раздел.
// Автор:      <ИМЯ ФАМИЛИЯ>
// Версия:     0.2.0
// Документ:   docs/DESIGN.md, раздел 2
{attribute 'qualified_only'}
VAR_GLOBAL CONSTANT
    // Пример FB_Example (шаблон; удаляется вместе с примером): допустимый диапазон уставки, % диапазона датчика
    EXAMPLE_SP_MIN_PCT : REAL := 0.0;
    EXAMPLE_SP_MAX_PCT : REAL := 100.0;
    EXAMPLE_SP_DEFAULT_PCT : REAL := 50.0;

    // Пример FB_Example: допустимый гистерезис, %. Нижняя граница защищает выход
    // от частых переключений при шуме измерения.
    EXAMPLE_HYST_MIN_PCT : REAL := 0.5;
    EXAMPLE_HYST_MAX_PCT : REAL := 20.0;
    EXAMPLE_HYST_DEFAULT_PCT : REAL := 5.0;

    // Предел счётчика включений: максимум UDINT, дальше счётчик не растёт (насыщение)
    EXAMPLE_COUNT_MAX : UDINT := 4294967295;

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
    STN_SEQ_START_TIMEOUT : TIME := T#30S;   // шаг последовательного пуска: пуск не подтвердился → следующий
    STN_ATS_WINDOW : TIME := T#10S;          // окно поиска насоса, введённого АВР (событие 101006)
    STN_LAMP_HALF_PERIOD : TIME := T#500MS;  // HL1 мигает 1 Гц
    STN_FULL_SPEED_PCT : REAL := 100.0;      // аварийный режим и по поплавкам
    // насос работает дольше — тревоги L/LL PT201 и L FT202 не подавляются (условно)
    STN_FLOW_SETTLE : TIME := T#20S;
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
    STN_CFG_TIMES : WORD := 16#0040;         // питание, tDryRelease, tLtRecover, tLvlConfirm
    STN_CFG_FLOAT_CHECK : WORD := 16#0080;   // rLdev*, tLdev
    STN_CFG_UNDERLOAD : WORD := 16#0100;
    STN_CFG_ALARM : WORD := 16#0200;         // приоритет тревоги вне перечисления
    STN_CFG_SETPOINT : WORD := 16#0400;      // rLevelSp_m вне rSpMin_eu…rSpMax_eu LIC101
    // диапазоны параметров 04 §18.2 — константы STN_<ПАРАМЕТР>_MIN / _MAX (полный список — при реализации)
    // ===== Модель (К2) =====
    SIM_TIME_SCALE_MAX : REAL := 50.0;       // k · T_MainTask ≤ 1 с (ARCHITECTURE, раздел 11)
    SIM_DT_SUBSTEP : LTIME := LTIME#200MS;   // шаг интегрирования резервуара
    SIM_AI_COUNT : UINT := 5;                // индексы aeAiFault/arAiForced_mA
    SIM_AI_LT101 : UINT := 1;
    SIM_AI_PT201 : UINT := 2;
    SIM_AI_FT202 : UINT := 3;
    SIM_AI_AT401 : UINT := 4;
    SIM_AI_AT402 : UINT := 5;
    SIM_MA_FAIL_LOW : REAL := 3.0;           // токи инъекций (NE 43: ≤ 3,6 — отказ)
    SIM_MA_UNDER_RANGE : REAL := 3.7;
    SIM_MA_OVER_RANGE : REAL := 20.8;
    SIM_MA_FAIL_HIGH : REAL := 22.0;
    SIM_GRAVITY_MPS2 : REAL := 9.81;
    SIM_RHO_KGM3 : REAL := 1000.0;
    SIM_HOURS_PER_DAY : REAL := 24.0;
    SIM_PROFILE_POINTS : UINT := 24;
    SIM_STORMS_MAX : UINT := 4;              // ливней в сутки, предел генератора
    SIM_PUMP_INTAKE_M : REAL := 0.30;        // ниже — насос подсасывает воздух (подача 0)
    SIM_VFD_FCODE_EXT : UINT := 11;          // условные коды аварии ПЧ (06 §5.4)
    SIM_VFD_FCODE_OVERHEAT : UINT := 12;
    SIM_VFD_FCODE_UNDERVOLT : UINT := 13;
    SIM_VFD_WATCHDOG : TIME := T#5S;         // сторожевой таймер связи ПЧ (04 §12)
    SIM_VFD_WATCHDOG_FREQ_HZ : REAL := 50.0; // предустановленная частота после срабатывания сторожевого таймера
    // частота местного поста ПЧ: в «Местном» FB_MotorVfd задание по сети не ведёт (следит за фактом), пуск по
    // месту — на предустановленной частоте (условно; на объекте — настройка ПЧ)
    SIM_VFD_LOCAL_FREQ_HZ : REAL := 50.0;
    SIM_BUTTON_PULSE : TIME := T#500MS;      // длительность нажатия кнопки шкафа в модели
    SIM_V1_FB_DELAY : TIME := T#1S;          // ОС вентилятора после команды
    // имитация разрешена сборкой; в targets/plc210 файл-наложение даёт FALSE (раздел 8.1)
    SIM_ALLOWED : BOOL := TRUE;
    SIM_DT_MAX : LTIME := LTIME#2S;          // больший шаг времени за вызов модели обрезается (пауза задачи, отладка)
    SIM_DAY_MAX : UDINT := 100000;           // предел счёта суток модели (≈ 270 лет): защита LREAL → UDINT
    SIM_VFD_COUNTS_PER_HZ : REAL := 100.0;   // FREF и FACT ПЧ: 0,01 Гц (= VFD_COUNTS_PER_PCT · 100 % / VFD_FREQ_NOM_HZ)
    SIM_IT_COUNTS_PER_A : REAL := 10.0;      // регистр тока ПЧ: 0,1 А (перечень, IT1n1: 0…600 отсчётов = 0…60 А)
    SIM_S_PER_H : REAL := 3600.0;            // с в часе: м³/ч ↔ м³/с
    SIM_PA_PER_BAR : REAL := 100000.0;
    SIM_W_PER_KW : REAL := 1000.0;
    SIM_SOLVER_ITERATIONS : UINT := 30;      // бисекция рабочей точки насосов (раздел 11.2)
    SIM_CLOG_K_FACTOR : REAL := 6.25;        // засор: крутизна характеристики ×6,25 — подача −60 % при том же напоре
    SIM_CLOG_I_FACTOR : REAL := 1.3;         // засор: ток ×1,3 к току того же насоса без засора
    SIM_STORM_RISE_SHARE : REAL := 0.15;     // трапеция ливня: рост 15 % длительности
    SIM_STORM_FALL_SHARE : REAL := 0.35;     // спад 35 % (полка — остальные 50 %)
    SIM_SEED_DAY_MUL : UDINT := 16#9E3779B9; // x0 = udiSeed XOR (сутки · 16#9E3779B9)
    SIM_XS_ZERO_STATE : DWORD := 16#2545F491; // замена нулевого состояния xorshift (из нуля генератор не выходит)
    SIM_XS_SHIFT_A : UINT := 13;             // F_Xorshift32: x ^= x << 13; x ^= x >> 17; x ^= x << 5
    SIM_XS_SHIFT_B : UINT := 17;
    SIM_XS_SHIFT_C : UINT := 5;
    SIM_U24_MASK : DWORD := 16#00FFFFFF;     // равномерное u = (x AND маска) / 2^24, точно в REAL
    SIM_U24_SCALE : REAL := 16777216.0;
    SIM_LT101_RANGE_M : REAL := 5.0;         // шкалы датчиков 4–20 мА (перечень сигналов), нижняя граница — 0
    SIM_PT201_RANGE_BAR : REAL := 10.0;
    SIM_FT202_RANGE_M3H : REAL := 500.0;
    SIM_AT401_RANGE_MGM3 : REAL := 40.0;
    SIM_AT402_RANGE_PCTLEL : REAL := 100.0;
END_VAR
