FOR uiI := 1 TO GVL_DeviceList.DEVICE_COUNT DO
    itfDev := aitfDevice[uiI];
    IF itfDev <> 0 THEN
        eMode := itfDev.Mode;
        IF axKnown[uiI] AND eMode <> aeModePrev[uiI] THEN
            udiChanges := udiChanges + 1;
            IF itfEvents <> 0 THEN
                itfEvents.LogEvent(eEvent := E_StationEvent.DeviceModeChanged,
                                   rValue := UINT_TO_REAL(auiDevNo[uiI] * GVL_Const.LOG_DEV_MODE_SCALE
                                                          + TO_UINT(eMode)));
            END_IF
        END_IF
        aeModePrev[uiI] := eMode;
        axKnown[uiI] := TRUE;
    END_IF
END_FOR
