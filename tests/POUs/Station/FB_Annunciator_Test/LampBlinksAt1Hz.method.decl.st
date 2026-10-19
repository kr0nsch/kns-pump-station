// 04 §14, PMI-36: HL1 мигает 1 Гц при неквитированных Medium и выше — 0,5 с горит, 0,5 с нет; Low не мигает
METHOD PRIVATE LampBlinksAt1Hz
VAR
    fbDut  : FB_Annunciator;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    uiStep : UINT;                    // шаг 100 мс
    fbDut2 : FB_Annunciator;          // второй экземпляр: только Low
END_VAR
