coUnit.TEST('PlcStartAdoption_PowerDeviceAfterPumpStopsRunningPump_A13');

stDiCfg := GVL_CfgProject.stES301Cfg;
stMotCfg := GVL_CfgProject.stP101Cfg;
stMotRet.eRemoteMode := PL.E_DeviceMode.Auto;
fbTime.Advance(tStep := T#100MS);
fbP101(xAutoRun := TRUE, xFbRun := TRUE, xExtFault := FALSE, xLocal := FALSE, xPowerOk := fbES301.xValue,
       xCommOk := TRUE, xVfdRunning := TRUE, xVfdReady := TRUE, xVfdFault := FALSE, rSpeedAct_pct := R_SPEED_PCT,
       itfTime := fbTime, stCmd := stMotCmd, stCfg := stMotCfg, stRetain := stMotRet);
fbES301(xIn := TRUE, xChannelFault := FALSE, itfTime := fbTime, stCmd := stDiCmd, stCfg := stDiCfg);

AssertFalse(Condition := fbP101.xQRun, Message := 'power read before ES301 call: run command dropped');
AssertTrue(Condition := fbP101.stSts.eState = PL.E_MotorState.Stopping, Message := 'adoption ends in Stopping');

coUnit.TEST_FINISHED();
