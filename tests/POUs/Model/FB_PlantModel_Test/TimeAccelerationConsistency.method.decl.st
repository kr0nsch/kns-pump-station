// Одинаковый процесс (приток 100 м³/ч, насос 1 пущен на 50 Гц) шагом 100 мс (k = 5) и шагом 1 с (k = 50)
// за 60 с времени модели: одно время модели, частота 50 Гц, уровни расходятся меньше 5 мм (разница — только
// дискретность рампы ПЧ в шаге вызова; резервуар интегрируется подшагами ≤ 200 мс).
METHOD PRIVATE TimeAccelerationConsistency
VAR
    fbTimeA : PL.FB_FakeTime;
    fbTimeB : PL.FB_FakeTime;
    fbA : FB_PlantModel;        // шаг 100 мс
    fbB : FB_PlantModel;        // шаг 1 с
    stCfg : ST_SimCfg;
    stCmdA : ST_SimCmd;
    stCmdB : ST_SimCmd;
    stFaultA : ST_FaultInjection;
    stFaultB : ST_FaultInjection;
    uiI : UINT;
END_VAR
