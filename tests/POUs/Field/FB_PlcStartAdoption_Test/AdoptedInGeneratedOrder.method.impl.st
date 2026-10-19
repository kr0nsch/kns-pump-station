coUnit.TEST('PlcStartAdoption_AdoptedInGeneratedOrder_A13');

stDiCfg := GVL_CfgProject.stES301Cfg;
stMotCfg := GVL_CfgProject.stP101Cfg;
stMotRet.eRemoteMode := PL.E_DeviceMode.Auto;
// первый вызов (старт ПЛК) в порядке PRG_Devices: ES301, затем P101 с напряжением от ES301
fbTime.Advance(tStep := T#100MS);
fbES301(xIn := TRUE, xChannelFault := FALSE, itfTime := fbTime, stCmd := stDiCmd, stCfg := stDiCfg);
fbP101(xAutoRun := TRUE, rSpeedSpAuto_pct := R_SPEED_PCT, xFbRun := TRUE, xExtFault := FALSE, xLocal := FALSE,
       xPowerOk := fbES301.xValue, xCommOk := TRUE, xVfdRunning := TRUE, xVfdReady := TRUE, xVfdFault := FALSE,
       rSpeedAct_pct := R_SPEED_PCT, itfTime := fbTime, stCmd := stMotCmd, stCfg := stMotCfg, stRetain := stMotRet);
AssertTrue(Condition := fbES301.xValue, Message := 'first call: power value without DI delay');
AssertTrue(Condition := fbP101.stSts.eState = PL.E_MotorState.Running, Message := 'first call: adopted');
AssertTrue(Condition := fbP101.xQRun, Message := 'first call: run command kept');

// дальше — 5 с по 100 мс в том же порядке
FOR uiStep := 1 TO 50 DO
    fbTime.Advance(tStep := T#100MS);
    fbES301(xIn := TRUE, xChannelFault := FALSE, itfTime := fbTime, stCmd := stDiCmd, stCfg := stDiCfg);
    fbP101(xAutoRun := TRUE, rSpeedSpAuto_pct := R_SPEED_PCT, xFbRun := TRUE, xExtFault := FALSE, xLocal := FALSE,
           xPowerOk := fbES301.xValue, xCommOk := TRUE, xVfdRunning := TRUE, xVfdReady := TRUE, xVfdFault := FALSE,
           rSpeedAct_pct := R_SPEED_PCT, itfTime := fbTime, stCmd := stMotCmd, stCfg := stMotCfg,
           stRetain := stMotRet);
END_FOR
AssertTrue(Condition := fbP101.stSts.eState = PL.E_MotorState.Running, Message := 'after 5 s: still running');
AssertTrue(Condition := fbP101.xQRun, Message := 'after 5 s: run command kept');
AssertEquals_UDINT(Expected := 0, Actual := stMotRet.udiOpCount, Message := 'adoption is not a start');
AssertEquals_WORD(Expected := 0, Actual := fbP101.stSts.stCommon.wFault, Message := 'no fault');

coUnit.TEST_FINISHED();
