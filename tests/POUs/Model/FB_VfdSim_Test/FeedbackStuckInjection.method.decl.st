// Инъекция «ОС залипла»: ПЧ стоит, реле «Работа» замкнуто.
METHOD PRIVATE FeedbackStuckInjection
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_VfdSim;          // проверяемая модель ПЧ
END_VAR
