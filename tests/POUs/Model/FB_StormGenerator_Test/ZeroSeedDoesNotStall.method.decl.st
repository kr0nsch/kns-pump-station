// seed 0 в сутки 0 даёт нулевое состояние xorshift — оно заменяется SIM_XS_ZERO_STATE; ливни
// детерминированы (эталон, до 4 в сутки: сутки 0 — 0, сутки 3 — 1, сутки 5 — 4).
METHOD PRIVATE ZeroSeedDoesNotStall
VAR
    fbDut : FB_StormGenerator;  // проверяемый генератор
    stCfg : ST_SimCfg;          // параметры ливней по умолчанию
END_VAR
