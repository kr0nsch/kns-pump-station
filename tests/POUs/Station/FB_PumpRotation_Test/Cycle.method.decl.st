// Помощник: uiSteps шагов времени tStep с одним требуемым числом. xPlant — подменные насосы в Auto
// следуют запросам: работают, если запрошены, доступны и без отказа (видно со следующего шага)
METHOD PRIVATE Cycle
VAR_IN_OUT
    fbDut    : FB_PumpRotation;                 // ФБ под тестом
    fbTime   : PL.FB_FakeTime;                  // подменное время
    stCfg    : ST_StationCfg;                   // уставки
    stRetain : ST_StationRetain;                // энергонезависимые данные
    afbPump  : ARRAY[1..3] OF FB_FakeMotorVfd;  // подменные насосы
END_VAR
VAR_INPUT
    uiRequired : UINT;                          // требуемое число насосов
    tStep      : TIME;                          // шаг времени
    uiSteps    : UINT;                          // шагов
    xPlant     : BOOL;                          // насосы следуют запросам
END_VAR
VAR
    uiStep : UINT;                              // номер шага
    uiIdx  : UINT;                              // насос
END_VAR
