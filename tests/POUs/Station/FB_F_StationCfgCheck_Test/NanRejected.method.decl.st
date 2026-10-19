// 04 §18.3: неконечные уставки (NaN) не проходят проверки своих групп
METHOD PRIVATE NanRejected
VAR
    stCfg : ST_StationCfg;              // уставки по умолчанию (04 §18.2)
    stPid : PL.ST_PidCfg;               // LIC101: пределы задания 1,2…2,2 м
    wErr  : WORD;                       // результат проверки
    uBits : PL.U_RealBits;            // сборка NaN по битам
END_VAR
