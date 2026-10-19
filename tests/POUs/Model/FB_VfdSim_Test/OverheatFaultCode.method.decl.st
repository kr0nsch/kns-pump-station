// Перегрев (TS1n2 разрывает цепь аварии): авария ПЧ с кодом 12, выбег.
METHOD PRIVATE OverheatFaultCode
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_VfdSim;          // проверяемая модель ПЧ
    uiI : UINT;
END_VAR
