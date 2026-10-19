// 04 §18.3: приоритет тревоги станции вне перечисления — STN_CFG_ALARM
METHOD PRIVATE AlarmBit
VAR
    stCfg : ST_StationCfg;              // уставки по умолчанию (04 §18.2)
    stPid : PL.ST_PidCfg;               // LIC101: пределы задания 1,2…2,2 м
    wErr  : WORD;                       // результат проверки
    pRaw : POINTER TO INT;           // значение вне перечисления
END_VAR
