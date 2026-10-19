AckAll := FALSE;
FOR uiI := 1 TO MIN(uiSlots, GVL_Const.ALM_SLOT_MAX + 1) DO
    AckAll := afbAlarm[uiI - 1].Ack() OR AckAll;
END_FOR
