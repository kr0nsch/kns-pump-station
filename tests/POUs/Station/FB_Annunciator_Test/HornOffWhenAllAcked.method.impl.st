coUnit.TEST('Annunciator_HornOffWhenAllAcked_A14_PMI36');

fbDut(itfTime := fbTime);
fbDut.auiUnack[3] := 1;
fbDut(udiNewHighSeq := 1, itfTime := fbTime);
fbDut.auiUnack[3] := 0;
fbDut.auiActive[3] := 1;
fbDut(itfTime := fbTime);
AssertFalse(Condition := fbDut.xHorn, Message := 'all acked: horn off');

coUnit.TEST_FINISHED();
