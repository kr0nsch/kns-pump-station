// 04 §18.2 № 13: uiDutyMax вне 1…3 — STN_CFG_DUTY
METHOD PRIVATE DutyBit
VAR
    stCfg : ST_StationCfg;              // уставки по умолчанию (04 §18.2)
    stPid : PL.ST_PidCfg;               // LIC101: пределы задания 1,2…2,2 м
    wErr  : WORD;                       // результат проверки
END_VAR
