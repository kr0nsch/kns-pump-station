// Время назад — мигание HL1 начинается заново с фазы «горит»
METHOD PRIVATE TimeBackwardsRestartsBlink
VAR
    fbDut  : FB_Annunciator;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    uiStep : UINT;                    // шаг 100 мс
END_VAR
