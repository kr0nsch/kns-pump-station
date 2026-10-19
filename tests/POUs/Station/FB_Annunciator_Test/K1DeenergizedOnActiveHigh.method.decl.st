// 04 §14, PMI-17, PMI-20: K1 под напряжением в норме, обесточено при активной High или Critical; Medium — нет
METHOD PRIVATE K1DeenergizedOnActiveHigh
VAR
    fbDut  : FB_Annunciator;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
END_VAR
