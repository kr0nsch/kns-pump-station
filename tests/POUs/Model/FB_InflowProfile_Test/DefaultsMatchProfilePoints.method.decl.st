// Профиль по умолчанию: в точке 8 ч — 1,60 · 70 = 112 м³/ч, в 3 ч — 0,38 · 70 = 26,6 м³/ч (06 §5.4: 27…112).
METHOD PRIVATE DefaultsMatchProfilePoints
VAR
    fbDut : FB_InflowProfile;   // проверяемый ФБ
    stCfg : ST_SimCfg;          // профиль по умолчанию
END_VAR
