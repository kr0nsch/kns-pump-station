// 04 §18.2 № 22–26: отметки и выдержка согласования поплавков вне диапазонов — STN_CFG_FLOAT_CHECK
METHOD PRIVATE FloatCheckBit
VAR
    stCfg : ST_StationCfg;              // уставки по умолчанию (04 §18.2)
    stPid : PL.ST_PidCfg;               // LIC101: пределы задания 1,2…2,2 м
    wErr  : WORD;                       // результат проверки
END_VAR
