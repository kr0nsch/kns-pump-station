// Фактическая частота 0,01 Гц: 5000 → 100 %, 2500 → 50 %, 1 → 0,02 %
METHOD PRIVATE DecodeScale5000Is100Pct
VAR
    fbDut : FB_VfdAdapter_Cond;     // проверяемый адаптер
END_VAR
