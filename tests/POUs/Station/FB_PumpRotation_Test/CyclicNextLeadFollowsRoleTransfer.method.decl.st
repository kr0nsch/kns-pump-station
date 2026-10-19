// 04 §8.1, §8.2, PMI-10, PMI-11: по кругу следующий ведущий отсчитывается от насоса, который стал ведущим, в том
// числе без нового пуска (передача роли по ограничению непрерывной работы). Иначе после передачи Н1 → Н2
// следующий пуск снова достался бы Н2, а Н3 простаивал бы
METHOD PRIVATE CyclicNextLeadFollowsRoleTransfer
VAR
    fbDut    : FB_PumpRotation;                    // ФБ под тестом
    fbTime   : PL.FB_FakeTime;                     // подменное время, старт 1 ч
    stCfg    : ST_StationCfg;                      // уставки по умолчанию, режим Cyclic
    stRetain : ST_StationRetain;                   // следующий ведущий (Cyclic)
    afbPump  : ARRAY[1..3] OF FB_FakeMotorVfd;     // подменные насосы: доступны, Auto, готовы, стоят
    fbSink   : FB_FakeEventSink;                   // подменный журнал
END_VAR
