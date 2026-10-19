// Отрицательный множитель (ошибка ввода профиля) не даёт отрицательного притока.
METHOD PRIVATE NegativeFactorGivesZeroInflow
VAR
    fbDut : FB_InflowProfile;   // проверяемый ФБ
    stCfg : ST_SimCfg;          // профиль по умолчанию
END_VAR
