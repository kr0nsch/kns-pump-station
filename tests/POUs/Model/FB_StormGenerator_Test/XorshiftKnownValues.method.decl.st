// F_Xorshift32: из 1 — 270369 (Marsaglia, 2003); из seed по умолчанию 20261016 — 552152043, затем
// 3072158977 (эталон).
METHOD PRIVATE XorshiftKnownValues
VAR
    dwX : DWORD;                // состояние генератора
END_VAR
