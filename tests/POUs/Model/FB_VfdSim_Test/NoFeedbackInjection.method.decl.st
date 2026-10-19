// Инъекция «нет ОС»: ПЧ вращает насос, реле «Работа» разомкнуто.
METHOD PRIVATE NoFeedbackInjection
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_VfdSim;          // проверяемая модель ПЧ
    uiI : UINT;
END_VAR
