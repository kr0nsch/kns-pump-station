// 04 §18.2 № 8, PMI-08 шаг 2: задание уровня вне пределов задания LIC101 — STN_CFG_SETPOINT
METHOD PRIVATE SetpointBit
VAR
    stCfg : ST_StationCfg;              // уставки по умолчанию (04 §18.2)
    stPid : PL.ST_PidCfg;               // LIC101: пределы задания 1,2…2,2 м
    wErr  : WORD;                       // результат проверки
END_VAR
