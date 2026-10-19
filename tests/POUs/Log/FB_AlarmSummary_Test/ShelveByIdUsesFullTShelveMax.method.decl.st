// ShelveById откладывает на весь tShelveMax тревоги (по умолчанию 8 ч), а не на свой срок: через 1 ч 1 с тревога
// ещё отложена, через 8 ч 1 с — снова ActiveUnack
METHOD PRIVATE ShelveByIdUsesFullTShelveMax
VAR_INST
    fbDut  : FB_AlarmSummary;       // проверяемая сводка
    stView : ST_AlarmView;          // список тревог
    fbSrc  : FB_TestAlarmSource;    // слот 0: tShelveMax по умолчанию (8 ч)
END_VAR
VAR
    fbTime : PL.FB_FakeTime;        // подменное время
    itfAlm : PL.I_Alarm;            // проверяемая тревога источника
END_VAR
