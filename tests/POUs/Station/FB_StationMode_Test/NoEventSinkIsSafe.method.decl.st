// Журнал не задан (itfEvents = 0) — переходы выполняются без обращения к журналу
METHOD PRIVATE NoEventSinkIsSafe
VAR
    fbDut    : FB_StationMode;                     // ФБ под тестом
    stRetain : ST_StationRetain;                   // энергонезависимые данные
END_VAR
