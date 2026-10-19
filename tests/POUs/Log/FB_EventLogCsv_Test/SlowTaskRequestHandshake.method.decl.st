// Обмен MainTask ↔ SlowTask через PRG_Slow и GVL_Log: запрос снимается, как только выгрузка началась
// (Writing); итог — Done и число строк; запрос сразу после Done (до следующего цикла SlowTask) запускает
// вторую выгрузку, а не теряется
METHOD PRIVATE SlowTaskRequestHandshake
VAR_INST
    fbTime  : PL.FB_FakeTime;       // время журнала (переживает циклы теста)
    uiPolls : UINT;                 // вызовов теста с начала
    iStep   : INT;                  // 0 — первый запрос, 1 — первая выгрузка, 2 — вторая выгрузка, 3 — итог
    xSecond : BOOL;                 // вторая выгрузка началась (Writing)
END_VAR
VAR
    uiI : UINT;                     // номер события
END_VAR
