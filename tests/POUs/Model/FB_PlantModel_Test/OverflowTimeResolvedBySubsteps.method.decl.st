// Шаг вызова 2 с (SIM_DT_MAX) делится на подшаги SIM_DT_SUBSTEP = 200 мс: уровень 4,595949 м, приток 250 м³/ч
// без насосов — отметка 4,6 м достигается в конце 4-го подшага (0,8 с), перелив — 7 подшагов = 1,4 с → 1 с.
// Одним шагом 2 с перелив был бы 2 с, подшагами по 0,4 с — 1,6 с → 2 с.
METHOD PRIVATE OverflowTimeResolvedBySubsteps
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
END_VAR
