// «Время назад»: шаг рампы 0 — частота не меняется; дальше рампа продолжается.
METHOD PRIVATE TimeBackwardsHoldsFrequency
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_VfdSim;          // проверяемая модель ПЧ
    uiI : UINT;
END_VAR
