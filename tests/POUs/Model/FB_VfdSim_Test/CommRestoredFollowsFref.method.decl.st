// После срабатывания таймера (50 Гц) связь восстановлена с заданием 3000: таймер снят, задание 30 Гц,
// через 4 с — 30 Гц, регистры снова обновляются (FACT 3000).
METHOD PRIVATE CommRestoredFollowsFref
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_VfdSim;          // проверяемая модель ПЧ
    uiI : UINT;
END_VAR
