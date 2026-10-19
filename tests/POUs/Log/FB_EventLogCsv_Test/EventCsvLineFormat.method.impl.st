coUnit.TEST('EventLogCsv_EventCsvLineFormat');

stRec.udiSeq := 1532;
stRec.uliUtc_ms := 1792136465120;
stRec.eKind := E_EventKind.Alarm;
stRec.udiId := 110;
stRec.ePriority := PL.E_AlarmPriority.Medium;
stRec.eOldState := PL.E_AlarmState.Normal;
stRec.eNewState := PL.E_AlarmState.ActiveUnack;
stRec.eReason := PL.E_AlarmEventReason.Activated;
stRec.rValue := 0.0;
AssertEquals_STRING(Expected := '1532;2026-10-16T07:41:05.120Z;alarm;110;P101.FTS;2;0;1;1;0.0$R$N',
                    Actual := F_EventCsvLine(stRecord := stRec), Message := 'alarm line');
stRec.udiSeq := 1533;
stRec.uliUtc_ms := 0;
stRec.eKind := E_EventKind.Station;
stRec.udiId := 101006;
stRec.ePriority := PL.E_AlarmPriority.None;
stRec.eNewState := PL.E_AlarmState.Normal;
stRec.eReason := PL.E_AlarmEventReason.None;
stRec.rValue := 3.0;
AssertEquals_STRING(Expected := '1533;;station;101006;KNS1.E6;0;0;0;0;3.0$R$N',
                    Actual := F_EventCsvLine(stRecord := stRec), Message := 'station line without clock');

coUnit.TEST_FINISHED();
