// Баланс массы с двумя насосами на 50 Гц (приток 120 м³/ч, уровень от 2,0 м): за 60 с изменение уровня равно
// сумме (Qin − Qout) · dt / 3600 / S по показанной подаче станции; подача станции — сумма подач насосов (равные
// насосы делят её поровну), FT202 показывает подачу станции (4 + 16 · Q / 500 мА).
METHOD PRIVATE MassBalanceTwoPumps
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
    uiI : UINT;
    lrLevel0_m : LREAL;         // уровень в начале учёта
    lrExpected_m : LREAL;       // уровень по балансу показанных потоков
END_VAR
