// Между точками — линейно: 8:30 — (1,60 + 1,50)/2 · 70 = 108,5 м³/ч; 8:45 — 1,525.
METHOD PRIVATE InterpolatesBetweenHours
VAR
    fbDut : FB_InflowProfile;   // проверяемый ФБ
    stCfg : ST_SimCfg;          // профиль по умолчанию
END_VAR
