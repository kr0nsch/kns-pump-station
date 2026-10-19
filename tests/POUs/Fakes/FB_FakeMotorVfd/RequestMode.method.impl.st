uiRequestModeCalls := uiRequestModeCalls + 1;
eLastModeRequest := eNewMode;
RequestMode := eNewMode = PL.E_DeviceMode.Auto OR eNewMode = PL.E_DeviceMode.Manual
               OR eNewMode = PL.E_DeviceMode.OutOfService;
IF RequestMode AND xFollowRequests THEN
    IF eMode = PL.E_DeviceMode.Local THEN
        eRememberedMode := eNewMode;
    ELSE
        eMode := eNewMode;
    END_IF
END_IF
