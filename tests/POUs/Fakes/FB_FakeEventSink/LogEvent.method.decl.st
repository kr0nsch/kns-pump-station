// Записать событие в кольцо (самое старое затирается); всегда TRUE
METHOD PUBLIC LogEvent : BOOL
VAR_INPUT
    eEvent : E_StationEvent;        // код события
    rValue : REAL;                  // значение
END_VAR
