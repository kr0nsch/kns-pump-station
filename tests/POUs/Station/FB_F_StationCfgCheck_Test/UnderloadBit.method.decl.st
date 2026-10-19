// 04 §18.2 № 28–30: порог тока выше 30 А — STN_CFG_UNDERLOAD; 0 (выключено) — допустимо
METHOD PRIVATE UnderloadBit
VAR
    stCfg : ST_StationCfg;              // уставки по умолчанию (04 §18.2)
    stPid : PL.ST_PidCfg;               // LIC101: пределы задания 1,2…2,2 м
    wErr  : WORD;                       // результат проверки
END_VAR
