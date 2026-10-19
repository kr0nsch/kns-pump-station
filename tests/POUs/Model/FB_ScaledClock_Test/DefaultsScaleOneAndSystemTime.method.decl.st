// Без Update: коэффициент 1, Now() — системное время (между двумя чтениями LTIME()).
METHOD PRIVATE DefaultsScaleOneAndSystemTime
VAR
    fbClock : FB_ScaledClock;   // проверяемые часы
    ltR0 : LTIME;               // системное время до чтения часов
    ltR1 : LTIME;               // после
    ltNow : LTIME;              // показание часов
END_VAR
