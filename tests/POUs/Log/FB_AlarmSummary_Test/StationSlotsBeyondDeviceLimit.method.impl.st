coUnit.TEST('AlarmSummary_StationSlotsBeyondDeviceLimit_PMI01_PMI30');

AssertEquals_UINT(Expected := GVL_Const.STN_ALARM_COUNT - 1, Actual := GVL_Const.ALM_SRC_SLOT_MAX,
                  Message := 'summary slot bound covers the station source');

fbStn.axCond[E_StationAlarm.SIM] := TRUE;
fbStn.axCond[E_StationAlarm.NOAUTO] := TRUE;
stCfg.astAlarm[E_StationAlarm.NOAUTO].tOnDelay := T#0S;
fbStn(itfTime := fbTime, stCfg := stCfg);
fbDut.aitfSource[1] := fbStn;
fbDut(uiSourceCount := 1, itfTime := fbTime, stView := stView);
AssertEquals_UINT(Expected := 2, Actual := stView.uiCount, Message := 'SIM and NOAUTO in the view');
AssertEquals_UINT(Expected := 2, Actual := stView.uiActiveTotal, Message := 'total not in Normal');
AssertEquals_UINT(Expected := 2, Actual := fbDut.auiActive[TO_UINT(PL.E_AlarmPriority.Low)],
                  Message := 'two Low active');
AssertTrue(Condition := fbDut.ePrioUnack = PL.E_AlarmPriority.Low, Message := 'Low unacked');
AssertTrue(Condition := (stView.astRow[1].udiId = 100013 AND stView.astRow[2].udiId = 100009)
                        OR (stView.astRow[1].udiId = 100009 AND stView.astRow[2].udiId = 100013),
           Message := 'rows 100013 and 100009');
AssertTrue(Condition := fbDut.AckById(udiId := 100013), Message := 'ack KNS1.SIM by id');
fbStn(itfTime := fbTime, stCfg := stCfg);
itfAlm := fbStn.GetAlarm(uiIndex := E_StationAlarm.SIM - 1);
AssertTrue(Condition := itfAlm.State = PL.E_AlarmState.ActiveAck, Message := 'KNS1.SIM acked');

coUnit.TEST_FINISHED();
