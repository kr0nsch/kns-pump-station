// 04 §6: волна — уровень опустился ниже пуска до конца выдержки: пуска нет, выдержка начинается заново
METHOD PRIVATE NoStartIfLevelDropsDuringConfirm
VAR
    fbDut  : FB_LevelControlStepped;    // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (04 §18.2)
END_VAR
