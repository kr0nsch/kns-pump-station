// AdvanceL вне ручного режима ничего не делает: часы по-прежнему равны системному времени (k = 1).
METHOD PRIVATE AdvanceIgnoredOutsideManual
VAR
    fbClock : FB_ScaledClock;
    ltR0 : LTIME;
    ltR1 : LTIME;
    ltNow : LTIME;
END_VAR
