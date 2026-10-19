// Ручной режим: Now() = заданное время, меняется только AdvanceL, коэффициент не влияет; после
// выключения часы продолжают от ручного времени (не назад).
METHOD PRIVATE ManualAdvance
VAR
    fbClock : FB_ScaledClock;
    ltR0 : LTIME;
    ltR1 : LTIME;
    ltNow : LTIME;
END_VAR
