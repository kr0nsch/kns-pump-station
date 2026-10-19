// Неконечное время суток — как 0 ч; неконечный средний приток — приток 0; выходы конечны.
METHOD PRIVATE NonFiniteInputsSafe
VAR
    fbDut : FB_InflowProfile;   // проверяемый ФБ
    stCfg : ST_SimCfg;          // профиль по умолчанию
    uBits : PL.U_RealBits;
END_VAR
