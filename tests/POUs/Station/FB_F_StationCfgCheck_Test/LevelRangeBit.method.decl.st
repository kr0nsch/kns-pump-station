// 04 §18.2 № 2–5: уровень вне диапазона или зазор пуска меньше 0,3 м — STN_CFG_LEVEL_RANGE; ровно 0,3 м —
// допустимо
METHOD PRIVATE LevelRangeBit
VAR
    stCfg : ST_StationCfg;              // уставки по умолчанию (04 §18.2)
    stPid : PL.ST_PidCfg;               // LIC101: пределы задания 1,2…2,2 м
    wErr  : WORD;                       // результат проверки
END_VAR
