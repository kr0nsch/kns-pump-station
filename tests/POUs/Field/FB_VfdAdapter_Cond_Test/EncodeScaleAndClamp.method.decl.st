// Задание частоты: 50 % → 2500, 12,345 % → 617 (округление), выше 100 % → 5000, ниже 0 → 0, 100 % → 5000
METHOD PRIVATE EncodeScaleAndClamp
VAR
    fbDut : FB_VfdAdapter_Cond;     // проверяемый адаптер
END_VAR
