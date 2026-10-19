// k = 1: часы совпадают с LTIME() и после нескольких чтений.
METHOD PRIVATE ScaleOneEqualsSystem
VAR
    fbClock : FB_ScaledClock;
    ltR0 : LTIME;
    ltR1 : LTIME;
    ltNow : LTIME;
END_VAR
