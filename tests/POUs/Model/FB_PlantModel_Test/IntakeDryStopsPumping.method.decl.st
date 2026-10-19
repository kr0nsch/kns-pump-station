// Уровень 0,25 м ниже приёмка: насос на 100 % не откачивает, уровень не падает, ток холостого хода 10,75 А.
METHOD PRIVATE IntakeDryStopsPumping
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
    uiI : UINT;
END_VAR
