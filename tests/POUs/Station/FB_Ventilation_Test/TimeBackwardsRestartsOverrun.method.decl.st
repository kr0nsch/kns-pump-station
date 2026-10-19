// Время назад — выбег tV1Overrun отсчитывается заново (вентилятор работает дольше, а не останавливается раньше)
METHOD PRIVATE TimeBackwardsRestartsOverrun
VAR
    fbDut  : FB_Ventilation;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию: выбег 10 мин
    uiStep : UINT;                      // шаг 1 с
END_VAR
