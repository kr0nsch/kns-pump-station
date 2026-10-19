// ResetDrive («ПЧ готовы», xResetPlant) снимает аварию, если причины уже нет, без фронта CTW.2;
// при активной причине авария остаётся.
METHOD PRIVATE ResetDriveClearsFault
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_VfdSim;          // проверяемая модель ПЧ
    uiI : UINT;
END_VAR
