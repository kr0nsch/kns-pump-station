// Первый вызов с питанием: ПЧ готов, связь есть, STW = готов + дистанционное (16#0011), частота и
// FACT 0, код аварии 0, реле разомкнуты.
METHOD PRIVATE DefaultsReadyAndStopped
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_VfdSim;          // проверяемая модель ПЧ
END_VAR
