// 04 §9.2: импульс сброса (фейсплейт, HS501, «Сбросить все») снимает фиксацию; отсчёт после сброса — заново
METHOD PRIVATE ResetClearsLatch
VAR
    fbDut  : FB_PumpProtection;         // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию: 12 А, 80 %, 15 с
END_VAR
