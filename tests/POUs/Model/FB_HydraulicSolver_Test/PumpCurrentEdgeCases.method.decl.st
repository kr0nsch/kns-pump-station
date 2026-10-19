// F_PumpCurrent: без вращения — 0; неконечный вход — 0; Pnom = 0 — 0; ток непрерывен при закрытии
// обратного клапана (подача 0,01 и 0 м³/ч дают одно значение 5,548 А на 60 %).
METHOD PRIVATE PumpCurrentEdgeCases
VAR
    stPump : ST_PumpModelCfg;   // характеристика по умолчанию
    uBits : PL.U_RealBits;
END_VAR
