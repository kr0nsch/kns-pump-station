// 04 §18.2 № 14–17: режим чередования вне перечисления, tMaxContRun между 0 и 10 мин — STN_CFG_ROTATION; 0 —
// выключено, допустимо
METHOD PRIVATE RotationBit
VAR
    stCfg : ST_StationCfg;              // уставки по умолчанию (04 §18.2)
    stPid : PL.ST_PidCfg;               // LIC101: пределы задания 1,2…2,2 м
    wErr  : WORD;                       // результат проверки
    pRaw : POINTER TO INT;           // значение вне перечисления
END_VAR
