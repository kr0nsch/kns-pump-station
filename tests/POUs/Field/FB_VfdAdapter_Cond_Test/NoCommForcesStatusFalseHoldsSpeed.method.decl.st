// Нет связи: регистры недостоверны — статусы FALSE (в том числе авария), скорость — последняя принятая (75 %);
// связь вернулась — снова по регистрам
METHOD PRIVATE NoCommForcesStatusFalseHoldsSpeed
VAR
    fbDut : FB_VfdAdapter_Cond;     // проверяемый адаптер
    wAll  : WORD;                   // все биты условной карты
END_VAR
