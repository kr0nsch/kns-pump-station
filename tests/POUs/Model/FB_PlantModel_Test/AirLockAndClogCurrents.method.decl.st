// Сухой ход Н1 на 100 %: подача 0, ток 10,75 А (регистр 108); засор Н2 на 100 %: подача 75,01 м³/ч,
// ток 34,30 А (регистр 343) — PMI-15. Уровень держится на 1,4 м (приток равен подаче).
METHOD PRIVATE AirLockAndClogCurrents
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
    uiI : UINT;
END_VAR
