// Перелив короче 1 с (один шаг 0,2 с на отметке перелива) виден в udiOverflow_s: не меньше 1 с. Иначе
// округление до целых секунд давало бы 0, и проверка «перелива нет (udiOverflow_s = 0)» PMI-20 и PMI-24
// проходила бы при настоящем переливе.
METHOD PRIVATE ShortOverflowCounted
VAR
    fbDut : FB_TankModel;       // проверяемый ФБ
END_VAR
