// 04 §18.2 № 9–12, §18.3: rAssistOff_pct <= rAssistOn_pct - 10 (ровно — допустимо), выдержки в диапазоне — иначе
// STN_CFG_PID_STAGING
METHOD PRIVATE PidStagingBit
VAR
    stCfg : ST_StationCfg;              // уставки по умолчанию (04 §18.2)
    stPid : PL.ST_PidCfg;               // LIC101: пределы задания 1,2…2,2 м
    wErr  : WORD;                       // результат проверки
END_VAR
