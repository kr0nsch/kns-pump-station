// 04 §14, PMI-36: новая неквитированная High/Critical (рост udiNewHighSeq) включает сирену; первый вызов принимает
// счётчик как есть
METHOD PRIVATE HornOnNewHighUnack
VAR
    fbDut  : FB_Annunciator;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
END_VAR
