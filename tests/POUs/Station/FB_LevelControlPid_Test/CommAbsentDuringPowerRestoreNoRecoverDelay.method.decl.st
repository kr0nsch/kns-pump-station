// 04 §7.4, §12, §13, VFD-12 plc-process-lib: напряжение восстановлено, насосы доступны, а ПЧ ещё загружаются
// (связи нет) — это не потеря связи: выдержка возврата STN_PID_RECOVER не перезапускается, ПИД готов, как только
// связь появилась. Вне окна восстановления питания прежнее правило: связь пропала у всех — возврат через 30 с
METHOD PRIVATE CommAbsentDuringPowerRestoreNoRecoverDelay
VAR
    fbDut   : FB_LevelControlPid;           // ФБ под тестом
    fbTime  : PL.FB_FakeTime;               // подменное время, старт 1 ч
    stCfg   : ST_StationCfg;                // уставки по умолчанию (04 §18.2)
    afbPump : ARRAY[1..3] OF FB_FakeMotorVfd;   // подменные насосы: доступны, Auto, стоят
    uiStep  : UINT;                         // шаг 100 мс
    uiIdx   : UINT;                         // насос
END_VAR
