// 04 §7.2: при уровне не ниже 2,40 м подпорный не отключается даже при малом выходе ПИД — на всём интервале:
// без условия по уровню подпорный отключался бы через tAssistOff и снова включался по уровню через tLvlConfirm
// («качели»), а проверка только в конце интервала этого не видит
METHOD PRIVATE AssistNotOffAboveAssistStartLevel
VAR
    fbDut    : FB_LevelControlPid;          // ФБ под тестом
    fbTime   : PL.FB_FakeTime;              // подменное время, старт 1 ч
    stCfg    : ST_StationCfg;               // уставки по умолчанию (04 §18.2)
    afbPump  : ARRAY[1..3] OF FB_FakeMotorVfd;  // подменные насосы
    uiStep   : UINT;                        // шаг 100 мс
    xDropped : BOOL;                        // требуемое число хоть раз было не 2
END_VAR
