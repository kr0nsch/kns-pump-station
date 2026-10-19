// 04 §18.2: уставки по умолчанию с отметками L 0,8 м и H 3,5 м проходят проверку
METHOD PRIVATE DefaultsPass
VAR
    stCfg : ST_StationCfg;              // уставки по умолчанию (04 §18.2)
    stPid : PL.ST_PidCfg;               // LIC101: пределы задания 1,2…2,2 м
    wErr  : WORD;                       // результат проверки
END_VAR
