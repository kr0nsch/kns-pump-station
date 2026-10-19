// 04 §6: границы включительно — пуск подпорного ровно при 2,40 м, останов подпорного ровно при 1,40 м; 1,59 м —
// без пуска
METHOD PRIVATE BoundaryLevelsInclusive
VAR
    fbDut  : FB_LevelControlStepped;    // ФБ под тестом
    fbTime : PL.FB_FakeTime;            // подменное время, старт 1 ч
    stCfg  : ST_StationCfg;             // уставки по умолчанию (04 §18.2)
    fbDut2 : FB_LevelControlStepped;   // второй экземпляр: уровень чуть ниже пуска
END_VAR
