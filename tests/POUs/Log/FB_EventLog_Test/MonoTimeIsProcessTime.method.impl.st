coUnit.TEST('EventLog_MonoTimeIsProcessTime');

fbLog.itfTime := fbTime;
fbLog.LogEvent(eEvent := E_StationEvent.RestartBegin, rValue := 0.0);
fbTime.Advance(tStep := T#90S);
fbLog.LogEvent(eEvent := E_StationEvent.RestartDone, rValue := 2.0);
fbLog.GetRecord(uiAge := 1, stRecord => stFirst);
fbLog.GetRecord(uiAge := 0, stRecord => stLast);
AssertEquals_LREAL(Expected := LREAL#90.0, Actual := stLast.lrMono_s - stFirst.lrMono_s, Delta := LR_EPS_S,
                   Message := 'interval = 90 s of process time');
AssertEquals_LREAL(Expected := LREAL#3690.0, Actual := stLast.lrMono_s, Delta := LR_EPS_S, Message := '1 h + 90 s');

coUnit.TEST_FINISHED();
