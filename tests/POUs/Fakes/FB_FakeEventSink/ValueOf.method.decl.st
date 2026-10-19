// Значение самого нового события eFind среди последних 16; нет такого — -1
METHOD PUBLIC ValueOf : REAL
VAR_INPUT
    eFind : E_StationEvent;         // искомый код
END_VAR
VAR
    uiStep  : UINT;                 // шаг назад от новейшего
    uiIdx   : UINT;                 // элемент кольца
    xFound  : BOOL;                 // найдено
END_VAR
