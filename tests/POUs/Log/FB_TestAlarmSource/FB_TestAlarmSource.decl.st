// Назначение: тестовый источник тревог (PL.I_AlarmSource) для FB_AlarmSummary_Test — до восьми PL.FB_Alarm с
//             условиями, номерами и настройками от теста; вызов тела выполняет запросы Ack/Shelve/Unshelve.
// Автор:      <ИМЯ ФАМИЛИЯ>
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, разделы 9.3, 14.1
FUNCTION_BLOCK FB_TestAlarmSource IMPLEMENTS PL.I_AlarmSource
VAR_INPUT
    uiSlots   : UINT;               // используемых слотов (AlarmCount), не больше ALM_SLOT_MAX + 1
    udiIdBase : UDINT;              // номер тревоги слота 0
    axIn      : ARRAY[0..GVL_Const.ALM_SLOT_MAX] OF BOOL;              // условия тревог
    astCfg    : ARRAY[0..GVL_Const.ALM_SLOT_MAX] OF PL.ST_AlarmCfg;    // настройки (умолчание — Medium, 8 ч)
    itfTime   : PL.I_TimeSource;    // подменное время теста
END_VAR
VAR
    afbAlarm : ARRAY[0..GVL_Const.ALM_SLOT_MAX] OF PL.FB_Alarm;   // тревоги слотов
    uiK      : UINT;                // номер слота, с 1
END_VAR
