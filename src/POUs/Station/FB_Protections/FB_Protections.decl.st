// Назначение: защиты станции и резервное управление (04 §10.1, 10.2, 10.5, 11): сухой ход,
//             аварийно высокий уровень, согласование поплавков и уровнемера (при годном уровнемере
//             виноват поплавок — маска; уровнемер вне диапазона по AI-13 plc-process-lib 1.0.0 негоден
//             и в согласовании не участвует), режим по поплавкам (ожидание LS102 / откачка до LS103).
//             Уровень для управления — xLevelUsable. Первый вызов (устройства ещё не вызывались) в
//             режим по поплавкам не переводит.
//             События 101011…101014. Демонстрация логики, не система ПАЗ (04 §10.7).
// Автор:      <ИМЯ ФАМИЛИЯ>
// Версия:     0.2.0
// Документ:   docs/DESIGN.md, раздел 6.7; docs/04_algorithms.md, разделы 10, 11
FUNCTION_BLOCK FB_Protections
VAR_INPUT
    rLevel_m    : REAL;             // fbLT101.rValue_eu
    xLevelValid : BOOL;             // fbLT101.xValid (NE 43, не OOS)
    eLevelNe107 : PL.E_Ne107Status; // fbLT101.stSts.stCommon.eNe107: OutOfSpecification — ток вне диапазона (LT101.OOR)
    xLevelL     : BOOL;             // fbLT101.xL, xLL, xH, xHH
    xLevelLL    : BOOL;
    xLevelH     : BOOL;
    xLevelHH    : BOOL;
    xFloatHigh  : BOOL;             // fbLS102.xValue (НЗ, обрыв = срабатывание)
    xFloatDry   : BOOL;             // fbLS103.xValue (eFailValue = ForceTrue)
    uiRunning   : UINT;             // работающие насосы (вход в режим по поплавкам)
    itfTime     : PL.I_TimeSource;
    itfEvents   : I_StationEventSink;
END_VAR
VAR_IN_OUT CONSTANT
    stCfg : ST_StationCfg;          // tDryRelease, rLdev*, tLdev, tLtRecover
END_VAR
VAR_OUTPUT
    xLevelUsable    : BOOL;         // = xLevelValid (вне диапазона — FALSE, AI-13): ступенчатое, ПИД, LIC101.xPvValid
    xDryRun         : BOOL;         // 04 §10.1 → KNS_ILK_DRY_RUN всем насосам; KNS1.DRY
    xEmergency      : BOOL;         // 04 §10.2 (взвод LS102 или HH; снятие ниже H)
    xFloatMode      : BOOL;         // 04 §11: NOT xLevelUsable; выход — tLtRecover годного сигнала
    uiFloatRequired : UINT;         // 0 — ожидание LS102; STN_PUMP_COUNT — откачка до LS103
    xLs102Masked    : BOOL;         // 04 §10.5
    xLs103Masked    : BOOL;
    xLdev           : BOOL;         // любое противоречие дольше tLdev (KNS1.LDEV)
    wLdev           : WORD;         // бит 0 LS102 ложно, 1 LS102 не сработал, 2 LS103 ложно, 3 LS103 не сработал
                                    // (STN_LDEV_*)
END_VAR
VAR
    fbLs102False  : PL.FB_Delay;    // LS102 сработал, уровень < rLdev102On_m (tLdev)
    fbLs102Missed : PL.FB_Delay;    // LS102 не сработал, уровень > rLdev102Off_m (tLdev)
    fbLs103False  : PL.FB_Delay;    // LS103 сработал, уровень > rLdev103On_m (tLdev)
    fbLs103Missed : PL.FB_Delay;    // LS103 не сработал, уровень < rLdev103Off_m (tLdev)
    fbDryRelease  : PL.FB_Delay;    // сухой ход без LT101: LS103 снят tDryRelease
    fbFloatExit   : PL.FB_Delay;    // уровень годен tLtRecover → выход из режима по поплавкам
    xFloatPumping : BOOL;           // режим по поплавкам: откачка (TRUE) или ожидание LS102
    xFirstCall    : BOOL := TRUE;   // первый вызов: выходы устройств ещё не посчитаны
END_VAR
VAR_TEMP
    xDryFloat   : BOOL;             // LS103 сработал и не исключён
    xDryLt      : BOOL;             // LL по годному уровнемеру
    xEhlFloat   : BOOL;             // LS102 сработал и не исключён
    xEhlLt      : BOOL;             // HH по годному уровнемеру
    xGood       : BOOL;             // уровнемер достоверен и в норме по NE 107 (виноват поплавок)
    xMaskPrev   : BOOL;             // маска поплавка до этого вызова (событие)
END_VAR
