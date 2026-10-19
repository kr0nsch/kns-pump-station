// Поплавки НЗ: LS102 срабатывает при уровне ≥ 4,20 м (FALSE), LS103 — при ≤ 0,40 м; StuckNormal —
// не срабатывает (TRUE), StuckTripped — сработал при любом уровне (FALSE).
METHOD PRIVATE FloatStuckNormalTripped
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
END_VAR
