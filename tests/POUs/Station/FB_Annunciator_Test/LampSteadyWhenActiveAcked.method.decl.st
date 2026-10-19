// 04 §14, PMI-36 шаг 3: активные квитированные — HL1 горит постоянно; нет активных — погашена
METHOD PRIVATE LampSteadyWhenActiveAcked
VAR
    fbDut  : FB_Annunciator;            // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    uiStep : UINT;                    // шаг 100 мс
    xEverOff : BOOL;                  // лампа гасла
END_VAR
