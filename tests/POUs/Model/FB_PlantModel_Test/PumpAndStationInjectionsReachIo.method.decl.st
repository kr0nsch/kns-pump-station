// Инъекции доходят до входов ПЛК: авария ПЧ Н2 (FLT, STW.2, код 11), перегрев Н1 (TS112 = FALSE, авария
// ПЧ, код 12), протечка Н3, «Местное» Н2, потеря связи с ПЧ Н3, затопление, пожар, ИБП, дверь, газы,
// потеря связи с TT403 (значение замирает), пропадание напряжения (ES301, YS302, ПЧ без связи).
METHOD PRIVATE PumpAndStationInjectionsReachIo
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
END_VAR
