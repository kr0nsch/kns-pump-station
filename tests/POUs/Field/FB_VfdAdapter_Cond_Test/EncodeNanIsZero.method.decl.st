// Неконечное задание (NaN, +Inf) — 0; бит сброса от задания не зависит
METHOD PRIVATE EncodeNanIsZero
VAR
    fbDut : FB_VfdAdapter_Cond;     // проверяемый адаптер
    uBits : PL.U_RealBits;          // сборка NaN и бесконечности из битов
END_VAR
