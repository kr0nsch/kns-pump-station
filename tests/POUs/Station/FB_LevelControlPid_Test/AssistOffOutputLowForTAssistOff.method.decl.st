// 04 §7.2, PMI-05: выход ПИД 75 % (граница включительно) дольше tAssistOff = 60 с при уровне ниже 2,40 м — один
// насос
METHOD PRIVATE AssistOffOutputLowForTAssistOff
VAR
    fbDut   : FB_LevelControlPid;           // ФБ под тестом
    fbTime  : PL.FB_FakeTime;               // подменное время, старт 1 ч
    stCfg   : ST_StationCfg;                // уставки по умолчанию (04 §18.2)
    afbPump : ARRAY[1..3] OF FB_FakeMotorVfd;   // подменные насосы
END_VAR
