coUnit.TEST('Annunciator_HornOnNewHighUnack_A14_PMI36');

fbDut(udiNewHighSeq := 5, itfTime := fbTime);
AssertFalse(Condition := fbDut.xHorn, Message := 'first call: counter accepted, no horn');
fbDut.auiUnack[3] := 1;
fbDut(udiNewHighSeq := 6, itfTime := fbTime);
AssertTrue(Condition := fbDut.xHorn, Message := 'new High unacked: horn');

coUnit.TEST_FINISHED();
