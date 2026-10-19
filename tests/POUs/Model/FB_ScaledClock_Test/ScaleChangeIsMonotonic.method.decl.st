// Смена коэффициента 1 → 50 → 1 → 20 перебазирует часы: время не идёт назад.
METHOD PRIVATE ScaleChangeIsMonotonic
VAR
    fbClock : FB_ScaledClock;
    altRead : ARRAY[1..6] OF LTIME;     // показания после каждой смены
END_VAR
