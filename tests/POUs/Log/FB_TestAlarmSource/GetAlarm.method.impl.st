IF uiIndex < MIN(uiSlots, GVL_Const.ALM_SLOT_MAX + 1) THEN
    GetAlarm := afbAlarm[uiIndex];
ELSE
    GetAlarm := 0;
END_IF
