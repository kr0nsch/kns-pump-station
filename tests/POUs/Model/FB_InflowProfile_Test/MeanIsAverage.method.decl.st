// Среднее за сутки (96 отсчётов через 15 мин) равно rAverage_m3h: среднее точек профиля — 1,0.
METHOD PRIVATE MeanIsAverage
VAR
    fbDut : FB_InflowProfile;   // проверяемый ФБ
    stCfg : ST_SimCfg;          // профиль по умолчанию
    uiI : UINT;
    rSum : REAL;               // сумма притока по отсчётам
END_VAR
