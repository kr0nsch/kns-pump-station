// xChanged — один вызов на смену управления (вход без рывка); без смены — FALSE
METHOD PRIVATE ChangedPulsesOnce
VAR
    fbDut : FB_ControlSelector;          // ФБ под тестом
END_VAR
