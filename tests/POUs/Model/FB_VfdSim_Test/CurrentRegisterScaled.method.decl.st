// Ток двигателя в регистре 102 — 0,1 А: 26,38 А → 264; неконечный ток и стоящий ПЧ — 0.
METHOD PRIVATE CurrentRegisterScaled
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_VfdSim;          // проверяемая модель ПЧ
    uiI : UINT;
    uBits : PL.U_RealBits;
END_VAR
