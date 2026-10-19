// 04 §7.4, PMI-28: выбран ПИД, ПИД не готов — Stepped и условие KNS1.STEP; готов — LevelPid без условия
METHOD PRIVATE PidNotReadyFallsBackToStepped
VAR
    fbDut : FB_ControlSelector;          // ФБ под тестом
END_VAR
