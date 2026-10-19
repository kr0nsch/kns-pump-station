// 04 §10.5, §11, PMI-26, AI-13 plc-process-lib 1.0.0: настоящий PL.FB_AnalogInput с уставками LT101 проекта.
// Ток 3,7 мА (выход за диапазон без отказа): до подтверждения (tFailDelay 2 с) значение годно, сухого хода нет;
// после — xValid = FALSE и NE 107 «вне спецификации»: сразу режим по поплавкам (101013). Уставки считаются по
// значению насыщения (LL уровнемера есть), но сухого хода по уровнемеру нет, противоречие с LS103 не считается
// (KNS1.LDEV нет): защиту держит поплавок
METHOD PRIVATE OorLtInvalidFloatsAtOnce
VAR
    fbDut   : FB_Protections;           // ФБ под тестом
    fbTime  : PL.FB_FakeTime;           // подменное время, старт 1 ч
    stCfg   : ST_StationCfg;            // уставки по умолчанию (tLdev 30 с)
    fbSink  : FB_FakeEventSink;         // подменный журнал
    stAiCmd : PL.ST_AnalogInputCmd;     // GVL_Hmi.stLT101Cmd
    stAiCfg : PL.ST_AnalogInputCfg;     // GVL_Persist.stLT101Cfg — уставки проекта
END_VAR
VAR_INST
    fbLT101 : PL.FB_AnalogInput;        // GVL_Devices.fbLT101
END_VAR
