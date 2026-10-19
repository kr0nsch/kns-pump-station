// И0 (06 §5.2): xClearFaults и xResetPlant в одном вызове — уровень 1,2 м, авария ПЧ снята без фронта
// CTW.2, ПЧ готов; пуск по проводу удержан — насос снова разгоняется.
METHOD PRIVATE ResetPlantRestoresLevelAndDrives
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
    uiI : UINT;
END_VAR
