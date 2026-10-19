// 04 §6, PMI-02: уровень 1,60 м (граница пуска ведущего) — пуск ровно через tLvlConfirm = 5 с, не на шаге раньше;
// частота — rStepSpeed_pct
METHOD PRIVATE StartsLeadAtStartLevelAfterConfirm
VAR
    fbDut  : FB_LevelControlStepped;    // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (04 §18.2)
END_VAR
