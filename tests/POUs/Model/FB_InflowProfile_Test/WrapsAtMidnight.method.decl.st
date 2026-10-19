// После 23 ч — к точке 0: 23:30 — (0,70 + 0,55)/2 = 0,625; время вне суток приводится по модулю:
// 24,25 ч = 0,25 ч; −0,5 ч = 23,5 ч.
METHOD PRIVATE WrapsAtMidnight
VAR
    fbDut : FB_InflowProfile;   // проверяемый ФБ
    stCfg : ST_SimCfg;          // профиль по умолчанию
    rRef : REAL;               // множитель в 0:15
END_VAR
