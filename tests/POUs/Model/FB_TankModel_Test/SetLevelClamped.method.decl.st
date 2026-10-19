// SetLevel ограничивает уровень 0…отметка перелива; неконечное значение не принимается.
METHOD PRIVATE SetLevelClamped
VAR
    fbDut : FB_TankModel;       // проверяемый ФБ
    uBits : PL.U_RealBits;
END_VAR
