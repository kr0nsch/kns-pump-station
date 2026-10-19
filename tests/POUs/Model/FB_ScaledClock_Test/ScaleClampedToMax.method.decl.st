// Коэффициент ограничивается 1…SIM_TIME_SCALE_MAX.
METHOD PRIVATE ScaleClampedToMax
VAR
    fbClock : FB_ScaledClock;
END_VAR
