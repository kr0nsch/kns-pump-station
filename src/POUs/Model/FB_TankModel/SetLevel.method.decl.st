// Установить уровень (xResetPlant, xSetLevel): ограничивается 0…rOverflow_m последнего вызова;
// неконечное значение не принимается. Выходы обновляет ближайший вызов тела
METHOD PUBLIC SetLevel
VAR_INPUT
    rNewLevel_m : REAL;     // новый уровень
END_VAR
