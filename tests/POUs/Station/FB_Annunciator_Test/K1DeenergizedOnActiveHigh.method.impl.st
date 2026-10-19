coUnit.TEST('Annunciator_K1DeenergizedOnActiveHigh_A14_PMI17');

fbDut(itfTime := fbTime);
AssertTrue(Condition := fbDut.xK1Energized, Message := 'normal: K1 energized');
fbDut.auiActive[2] := 3;
fbDut(itfTime := fbTime);
AssertTrue(Condition := fbDut.xK1Energized, Message := 'Medium only: K1 energized');
fbDut.auiActive[4] := 1;
fbDut(itfTime := fbTime);
AssertFalse(Condition := fbDut.xK1Energized, Message := 'Critical active: K1 de-energized');
fbDut.auiActive[4] := 0;
fbDut.auiActive[3] := 1;
fbDut(itfTime := fbTime);
AssertFalse(Condition := fbDut.xK1Energized, Message := 'High active: K1 de-energized');

coUnit.TEST_FINISHED();
