// 04 §7.2, PMI-05: выход ПИД 98 % (граница включительно) дольше tAssistOn = 30 с — второй насос, не раньше
METHOD PRIVATE AssistOnOutputHighForTAssistOn
VAR
    fbDut   : FB_LevelControlPid;           // ФБ под тестом
    fbTime  : PL.FB_FakeTime;               // подменное время, старт 1 ч
    stCfg   : ST_StationCfg;                // уставки по умолчанию (04 §18.2)
    afbPump : ARRAY[1..3] OF FB_FakeMotorVfd;   // подменные насосы
END_VAR
