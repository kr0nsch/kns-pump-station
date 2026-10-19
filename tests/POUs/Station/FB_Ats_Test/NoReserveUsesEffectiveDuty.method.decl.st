// 04 §5.1, §6, §7.2, §15, PMI-32: в обычном режиме работает не больше MIN(uiDutyMax, STN_DUTY_MAX) насосов
// (ступенчатое и ПИД — до двух). При допустимом uiDutyMax = 3 три доступных насоса — это два рабочих и резерв:
// условие KNS1.NORES ложно (иначе постоянная High-тревога при исправной станции)
METHOD PRIVATE NoReserveUsesEffectiveDuty
VAR
    fbDut   : FB_Ats;                          // ФБ под тестом
    fbTime  : PL.FB_FakeTime;                  // подменное время, старт 1 ч
    stCfg   : ST_StationCfg;                   // уставки по умолчанию, uiDutyMax = 3
    afbPump : ARRAY[1..3] OF FB_FakeMotorVfd;  // подменные насосы: доступны, Auto
    fbSink  : FB_FakeEventSink;                // подменный журнал
END_VAR
