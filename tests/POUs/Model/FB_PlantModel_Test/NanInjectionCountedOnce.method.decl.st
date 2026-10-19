// Неконечное значение в поле REAL инъекций (запись NaN по OPC UA или сценарием) — одно изменение, а не
// изменение в каждом вызове: иначе udiFaultSeq рос бы 50 раз в секунду и событие 101021 затирало бы журнал
// на 200 записей за секунды. Возврат к конечному значению — тоже одно изменение.
METHOD PRIVATE NanInjectionCountedOnce
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
    uBits : PL.U_RealBits;
    uiI : UINT;
END_VAR
