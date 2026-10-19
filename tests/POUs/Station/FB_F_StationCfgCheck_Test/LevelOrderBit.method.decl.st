// 04 §1, PMI-08 шаг 3: нарушен порядок отметок (останов подпорного выше пуска ведущего; H ниже пуска подпорного) —
// STN_CFG_LEVEL_ORDER
METHOD PRIVATE LevelOrderBit
VAR
    stCfg : ST_StationCfg;              // уставки по умолчанию (04 §18.2)
    stPid : PL.ST_PidCfg;               // LIC101: пределы задания 1,2…2,2 м
    wErr  : WORD;                       // результат проверки
END_VAR
