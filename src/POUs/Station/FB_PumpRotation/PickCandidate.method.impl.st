PickCandidate := 0;
IF xNeedComm THEN
    PickCandidate := PickIn(eRot := eRot, uiNext := uiNext, xRequireCommOk := TRUE, xRequireReady := TRUE);
    IF PickCandidate = 0 AND NOT xReadyOnly THEN
        PickCandidate := PickIn(eRot := eRot, uiNext := uiNext, xRequireCommOk := TRUE, xRequireReady := FALSE);
    END_IF
END_IF
IF PickCandidate = 0 THEN
    PickCandidate := PickIn(eRot := eRot, uiNext := uiNext, xRequireCommOk := FALSE, xRequireReady := TRUE);
END_IF
IF PickCandidate = 0 AND NOT xReadyOnly THEN
    PickCandidate := PickIn(eRot := eRot, uiNext := uiNext, xRequireCommOk := FALSE, xRequireReady := FALSE);
END_IF
