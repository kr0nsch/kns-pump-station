// Откладывание по номеру: tShelveMax = 0 — отказ; 1 ч — принято, через 1 ч откладывание истекает и активная
// тревога снова ActiveUnack
METHOD PRIVATE ShelveByIdRespectsTShelveMax
VAR_INST
    fbDut  : FB_AlarmSummary;       // проверяемая сводка
    stView : ST_AlarmView;          // список тревог
    fbSrc  : FB_TestAlarmSource;    // слот 0: откладывать нельзя; слот 1: до 1 ч
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    itfAlm : PL.I_Alarm;            // проверяемая тревога источника
END_VAR
