// 04 §4: старшинство в «Автомате» PowerLost > Restart > DryRunStop > Float > Emergency > LevelPid > Stepped — для
// каждой пары условий побеждает старшее (все 2^5 сочетаний пяти условий при выбранном и готовом ПИД)
METHOD PRIVATE PrecedenceTable
VAR
    fbDut : FB_ControlSelector;          // ФБ под тестом

    uiMask   : UINT;                    // сочетание условий: бит 0 PowerLost … бит 4 Emergency
    eExpect  : E_ControlAct;            // ожидаемое управление
    xAllOk   : BOOL := TRUE;            // все сочетания дали ожидаемое
    uiBad    : UINT;                    // первое неверное сочетание
END_VAR
