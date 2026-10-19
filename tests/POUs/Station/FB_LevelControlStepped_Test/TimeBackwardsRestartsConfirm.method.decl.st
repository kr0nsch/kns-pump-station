// Время назад (сбой источника) — выдержка подтверждения начинается заново, ложного пуска нет
METHOD PRIVATE TimeBackwardsRestartsConfirm
VAR
    fbDut  : FB_LevelControlStepped;    // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (04 §18.2)
END_VAR
