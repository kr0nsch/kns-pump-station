// Запрос режима: считается; Auto, Manual, OutOfService — TRUE, Local и прочее — FALSE (как I_Device)
METHOD PUBLIC RequestMode : BOOL
VAR_INPUT
    eNewMode : PL.E_DeviceMode;     // требуемый режим
END_VAR
