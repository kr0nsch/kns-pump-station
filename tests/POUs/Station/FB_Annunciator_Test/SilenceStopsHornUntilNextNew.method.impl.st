coUnit.TEST('Annunciator_SilenceStopsHornUntilNextNew_A14_PMI36');

fbDut(itfTime := fbTime);
fbDut.auiUnack[4] := 1;
fbDut(udiNewHighSeq := 1, itfTime := fbTime);
fbDut(xSilence := TRUE, itfTime := fbTime);
AssertFalse(Condition := fbDut.xHorn, Message := 'silenced');
fbDut(xSilence := FALSE, itfTime := fbTime);
AssertFalse(Condition := fbDut.xHorn, Message := 'stays silent while unacked');
fbDut(udiNewHighSeq := 2, itfTime := fbTime);
AssertTrue(Condition := fbDut.xHorn, Message := 'next new alarm: horn again');

coUnit.TEST_FINISHED();
