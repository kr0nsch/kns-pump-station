coUnit.TEST('AlarmSummary_SlotMaxMatchesLibrary');

AssertEquals_UINT(Expected := PL.GVL_Const.DEV_ALARMS_MAX - 1, Actual := GVL_Const.ALM_SLOT_MAX,
                  Message := 'ALM_SLOT_MAX = DEV_ALARMS_MAX - 1');

coUnit.TEST_FINISHED();
