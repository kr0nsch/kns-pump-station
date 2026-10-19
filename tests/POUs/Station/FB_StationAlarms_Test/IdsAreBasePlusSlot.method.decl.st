// 04 §15, API 20.5: номер тревоги = 100000 + slot; индекс источника 0 — slot 1; AlarmCount = 13
METHOD PRIVATE IdsAreBasePlusSlot
VAR
    fbDut  : FB_StationAlarms;          // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // тревоги по умолчанию (05_alarm_list.csv)
    itfAlm : PL.I_Alarm;              // тревога через интерфейс
    uiIdx  : UINT;                    // индекс источника
    xIdsOk : BOOL := TRUE;            // все номера верны
END_VAR
