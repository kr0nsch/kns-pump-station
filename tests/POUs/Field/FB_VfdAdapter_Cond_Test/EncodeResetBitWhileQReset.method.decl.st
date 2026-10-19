// Слово управления: бит сброса аварии (CTW.2), пока есть импульс xQReset; бит пуска не используется
METHOD PRIVATE EncodeResetBitWhileQReset
VAR
    fbDut : FB_VfdAdapter_Cond;     // проверяемый адаптер
END_VAR
