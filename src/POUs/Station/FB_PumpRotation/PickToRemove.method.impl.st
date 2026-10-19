PickToRemove := 0;
FOR uiIdx := 1 TO GVL_Const.STN_PUMP_COUNT DO
    IF axReq[uiIdx] THEN
        IF eRot = E_RotationMode.RunHours THEN
            // наоборот к выбору при пуске: насос, который проигрывает всем остальным
            IF PickToRemove = 0 THEN
                PickToRemove := uiIdx;
            ELSIF Better(uiA := PickToRemove, uiB := uiIdx, eRot := eRot, uiNext := 1) THEN
                PickToRemove := uiIdx;
            END_IF
        ELSIF uiIdx <> uiLeadIdx THEN
            IF PickToRemove = 0 THEN
                PickToRemove := uiIdx;
            ELSIF audiReqSeq[uiIdx] > audiReqSeq[PickToRemove] THEN
                PickToRemove := uiIdx;
            END_IF
        END_IF
    END_IF
END_FOR
IF PickToRemove = 0 AND uiLeadIdx >= 1 AND uiLeadIdx <= GVL_Const.STN_PUMP_COUNT THEN
    IF axReq[uiLeadIdx] THEN
        PickToRemove := uiLeadIdx;
    END_IF
END_IF
