// Разные частоты: 100 % и 60 % — у второго H0·0,36 = 12,4 м < напора 20,9 м, обратный клапан закрыт
// (подача 0, ток холостого хода 5,548 А); 100 % и 90 % — подают оба (120,46 и 60,77 м³/ч).
METHOD PRIVATE UnequalSpeedsCheckValveClosed
VAR
    fbDut : FB_HydraulicSolver; // проверяемый ФБ
    stCfg : ST_SimCfg;          // характеристика насоса по умолчанию (stCfg.stPump)
END_VAR
