// Сколько событий с кодом eFind среди последних 16
METHOD PUBLIC CountOf : UINT
VAR_INPUT
    eFind : E_StationEvent;         // искомый код
END_VAR
VAR
    uiIdx  : UINT;                  // элемент кольца
    uiUsed : UINT;                  // заполнено элементов
END_VAR
