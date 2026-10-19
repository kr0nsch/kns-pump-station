// 04 §18.2 № 7: частота ступенчатого режима вне 60…100 % — STN_CFG_SPEED
METHOD PRIVATE SpeedBit
VAR
    stCfg : ST_StationCfg;              // уставки по умолчанию (04 §18.2)
    stPid : PL.ST_PidCfg;               // LIC101: пределы задания 1,2…2,2 м
    wErr  : WORD;                       // результат проверки
END_VAR
