FOR uiK := 1 TO MIN(uiSlots, GVL_Const.ALM_SLOT_MAX + 1) DO
    afbAlarm[uiK - 1](xIn := axIn[uiK - 1], udiId := udiIdBase + uiK - 1, stCfg := astCfg[uiK - 1], itfTime := itfTime);
END_FOR
