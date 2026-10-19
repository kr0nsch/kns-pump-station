// «Местное»: провод «Пуск» от ПЛК не действует, пуск — с местного поста; бит STW.4 (дистанционное)
// снят.
METHOD PRIVATE LocalRun
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_VfdSim;          // проверяемая модель ПЧ
    uiI : UINT;
END_VAR
