// И0 (06 §5.2) перед каждой проверкой — xResetPlant: время перелива udiOverflow_s прошлой проверки
// обнуляется, иначе «перелива нет (SimSts.udiOverflow_s = 0)» PMI-20 и PMI-24 зависело бы от порядка
// проверок. Перелив: 4,55 м, приток 250 м³/ч без насосов, 60 с.
METHOD PRIVATE ResetPlantClearsOverflowTime
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
    uiI : UINT;
END_VAR
