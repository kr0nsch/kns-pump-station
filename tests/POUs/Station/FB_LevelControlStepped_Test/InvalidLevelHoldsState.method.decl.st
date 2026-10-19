// 04 §6: недостоверный уровень (и NaN при xLevelValid) — число насосов держится, выдержки не идут
METHOD PRIVATE InvalidLevelHoldsState
VAR
    fbDut  : FB_LevelControlStepped;    // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (04 §18.2)
    rNan   : REAL;                     // NaN
    uBits  : PL.U_RealBits;             // сборка NaN по битам
END_VAR
