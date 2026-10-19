// xPressReset: HS501 нажата 500 мс (0,4 с — нажата, 0,5 с — отпущена), импульс команды сброшен; HS502 не нажата.
METHOD PRIVATE ButtonsPulse
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
    uiI : UINT;
END_VAR
