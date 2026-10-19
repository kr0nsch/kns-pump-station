// 04 §6, PMI-03: подпорный — пуск при 2,40 м, между 1,40 и 2,40 м число держится, останов подпорного при 1,40 м;
// ведущий работает выше 1,00 м
METHOD PRIVATE AssistOnAndOffWithHysteresis
VAR
    fbDut  : FB_LevelControlStepped;    // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (04 §18.2)
END_VAR
