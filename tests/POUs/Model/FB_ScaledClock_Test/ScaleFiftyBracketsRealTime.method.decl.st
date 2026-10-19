// k = 50: интервал часов между двумя чтениями лежит в «вилке» 50 · (интервал системного времени),
// посчитанной по чтениям LTIME() до и после каждого показания; часы монотонны (1000 чтений подряд).
METHOD PRIVATE ScaleFiftyBracketsRealTime
VAR
    fbClock : FB_ScaledClock;
    ltRa0 : LTIME;              // системное время вокруг первого показания
    ltRa1 : LTIME;
    ltRb0 : LTIME;              // вокруг второго
    ltRb1 : LTIME;
    ltSa : LTIME;               // показания часов
    ltSb : LTIME;
    ltPrev : LTIME;
    ltCur : LTIME;
    uiI : UINT;
    xMono : BOOL := TRUE;       // все чтения не убывают
    lrScaled_ns : LREAL;        // интервал часов
    lrLow_ns : LREAL;           // нижняя граница вилки
    lrHigh_ns : LREAL;          // верхняя граница
END_VAR
