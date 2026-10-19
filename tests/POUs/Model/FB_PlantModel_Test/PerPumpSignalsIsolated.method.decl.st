// Каждый насос — свои входы ПЛК (имена GVL_IO у насосов разные, блоки в модели явные). Для насоса i:
// инъекции перегрева, протечки, «Местного», аварии ПЧ и потери связи меняют только TS1i2, MS1i3, HS1i4,
// P10i_FLT, P10i_FCODE и xMbOk_RS485_1_Si; в работе только насоса i частота, ток, реле «Работа» — только у него.
METHOD PRIVATE PerPumpSignalsIsolated
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
    stFaultNone : ST_FaultInjection;  // все инъекции сняты
    uiPump : UINT;              // насос с инъекцией или в работе
    uiJ : UINT;                 // проверяемый насос
    uiI : UINT;
    axTs : ARRAY[1..GVL_Const.STN_PUMP_COUNT] OF BOOL;      // TS1n2 (НЗ: TRUE — норма)
    axMs : ARRAY[1..GVL_Const.STN_PUMP_COUNT] OF BOOL;      // MS1n3
    axHs : ARRAY[1..GVL_Const.STN_PUMP_COUNT] OF BOOL;      // HS1n4
    axFlt : ARRAY[1..GVL_Const.STN_PUMP_COUNT] OF BOOL;     // P10n_FLT
    axRfb : ARRAY[1..GVL_Const.STN_PUMP_COUNT] OF BOOL;     // P10n_RFB
    axMbOk : ARRAY[1..GVL_Const.STN_PUMP_COUNT] OF BOOL;    // xMbOk_RS485_1_Sn
    auiFact : ARRAY[1..GVL_Const.STN_PUMP_COUNT] OF UINT;   // P10n_FACT
    auiIt : ARRAY[1..GVL_Const.STN_PUMP_COUNT] OF UINT;     // IT1n1
    auiFcode : ARRAY[1..GVL_Const.STN_PUMP_COUNT] OF UINT;  // P10n_FCODE
END_VAR
