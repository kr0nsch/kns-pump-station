// Первый вызов с параметрами по умолчанию: уровень 1,2 м (LT101 7,84 мА), насосы стоят (PT201 —
// столб 1,1772 бар = 5,8835 мА, FT202 4 мА), газы — фон (4,24 мА), поплавки и ввод в норме, ПЧ готовы
// (STW 16#0011), обмен исправен, TT403 18 °C, приток в 0 ч — 0,55 · 70 = 38,5 м³/ч.
METHOD PRIVATE DefaultsInitialState
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_PlantModel;      // проверяемая модель
    stCfg : ST_SimCfg;          // параметры по умолчанию
    stCmd : ST_SimCmd;          // команды модели
    stFault : ST_FaultInjection;  // инъекции
END_VAR
