// 04 §5.2 п. 3, §8.2, §12, PMI-11: в ПИД замена ведущего при передаче роли — только готовый насос со связью с ПЧ.
// Резерв без связи роль не получает (иначе после перекрытия ведущим стал бы насос без связи, ПИД потерял бы
// готовность и станция ушла бы в ступенчатое с KNS1.STEP) — повтор через STN_HANDOVER_RETRY
METHOD PRIVATE HandoverLeadNeedsCommInPid
VAR
    fbDut    : FB_PumpRotation;                    // ФБ под тестом
    fbTime   : PL.FB_FakeTime;                     // подменное время, старт 1 ч
    stCfg    : ST_StationCfg;                      // уставки по умолчанию (RunHours, tStagger 5 с)
    stRetain : ST_StationRetain;                   // следующий ведущий (Cyclic)
    afbPump  : ARRAY[1..3] OF FB_FakeMotorVfd;     // подменные насосы: доступны, Auto, готовы, стоят
    fbSink   : FB_FakeEventSink;                   // подменный журнал
END_VAR
