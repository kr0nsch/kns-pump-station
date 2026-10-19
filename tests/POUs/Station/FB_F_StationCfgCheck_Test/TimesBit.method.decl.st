// 04 §18.2 № 6, 18–21, 27, 31: выдержки вне диапазонов — STN_CFG_TIMES
METHOD PRIVATE TimesBit
VAR
    stCfg : ST_StationCfg;              // уставки по умолчанию (04 §18.2)
    stPid : PL.ST_PidCfg;               // LIC101: пределы задания 1,2…2,2 м
    wErr  : WORD;                       // результат проверки
END_VAR
