// xStormNow: трапеция 10 мин, пик 200 м³/ч (ливни генератора и профиль выключены): 45 с — 100,
// 90 с — 200, 300 с — 200, 495 с — 100, после 600 с — 0, ливень закончился. При постоянном притоке команда
// не действует, импульс сбрасывается.
METHOD PRIVATE StormNowTrapezoid
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
    uiI : UINT;
END_VAR
