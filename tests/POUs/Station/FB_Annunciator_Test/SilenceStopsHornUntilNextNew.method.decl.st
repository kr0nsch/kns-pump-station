// 04 §14, PMI-36 шаг 2: «Звук» выключает сирену до следующей новой тревоги
METHOD PRIVATE SilenceStopsHornUntilNextNew
VAR
    fbDut  : FB_Annunciator;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
END_VAR
