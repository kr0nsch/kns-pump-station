F_FaultInjEqual := FALSE;
FOR uiI := 1 TO GVL_Const.STN_PUMP_COUNT DO
    IF stA.axVfdFault[uiI] <> stB.axVfdFault[uiI] OR stA.axNoFeedback[uiI] <> stB.axNoFeedback[uiI]
       OR stA.axFeedbackStuck[uiI] <> stB.axFeedbackStuck[uiI] OR stA.axAirLock[uiI] <> stB.axAirLock[uiI]
       OR stA.axClog[uiI] <> stB.axClog[uiI] OR stA.axOverheat[uiI] <> stB.axOverheat[uiI]
       OR stA.axLeak[uiI] <> stB.axLeak[uiI] OR stA.axVfdCommLoss[uiI] <> stB.axVfdCommLoss[uiI]
       OR stA.axLocal[uiI] <> stB.axLocal[uiI] OR stA.axLocalRun[uiI] <> stB.axLocalRun[uiI] THEN
        RETURN;
    END_IF
END_FOR
FOR uiI := 1 TO GVL_Const.SIM_AI_COUNT DO
    IF stA.aeAiFault[uiI] <> stB.aeAiFault[uiI] OR stA.arAiForced_mA[uiI] <> stB.arAiForced_mA[uiI] THEN
        RETURN;
    END_IF
END_FOR
IF stA.eLs102Stuck <> stB.eLs102Stuck OR stA.eLs103Stuck <> stB.eLs103Stuck OR stA.xPowerLoss <> stB.xPowerLoss
   OR stA.xUpsFault <> stB.xUpsFault OR stA.xTempCommLoss <> stB.xTempCommLoss OR stA.xFanFault <> stB.xFanFault
   OR stA.xFanNoFeedback <> stB.xFanNoFeedback OR stA.xValveChamberFlood <> stB.xValveChamberFlood
   OR stA.xFire <> stB.xFire OR stA.rH2S_mgm3 <> stB.rH2S_mgm3 OR stA.rCh4_pctLel <> stB.rCh4_pctLel THEN
    RETURN;
END_IF
F_FaultInjEqual := TRUE;
