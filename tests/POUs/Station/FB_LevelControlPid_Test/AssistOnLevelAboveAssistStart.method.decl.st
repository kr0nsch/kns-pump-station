// 04 §7.2: уровень не ниже rLvlStartAssist_m = 2,40 м дольше tLvlConfirm — второй насос и при малом выходе ПИД
METHOD PRIVATE AssistOnLevelAboveAssistStart
VAR
    fbDut   : FB_LevelControlPid;           // ФБ под тестом
    fbTime  : PL.FB_FakeTime;               // подменное время, старт 1 ч
    stCfg   : ST_StationCfg;                // уставки по умолчанию (04 §18.2)
    afbPump : ARRAY[1..3] OF FB_FakeMotorVfd;   // подменные насосы
END_VAR
