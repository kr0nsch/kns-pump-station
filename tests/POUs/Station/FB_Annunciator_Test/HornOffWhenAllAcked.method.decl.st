// 04 §14: квитирование всех High/Critical выключает сирену
METHOD PRIVATE HornOffWhenAllAcked
VAR
    fbDut  : FB_Annunciator;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
END_VAR
