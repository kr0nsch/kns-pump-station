// Способ вне перечисления — как «Ступенчатое» (E_ControlMethod: безопасный вариант)
METHOD PRIVATE GarbageMethodIsStepped
VAR
    fbDut : FB_ControlSelector;          // ФБ под тестом
    pRaw : POINTER TO INT;             // способ вне перечисления
    eBad  : E_ControlMethod;            // мусор
END_VAR
