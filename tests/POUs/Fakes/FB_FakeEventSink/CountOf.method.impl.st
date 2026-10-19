CountOf := 0;
IF udiCount > RING_LAST THEN
    uiUsed := RING_LAST + 1;
ELSE
    uiUsed := UDINT_TO_UINT(udiCount);
END_IF
FOR uiIdx := 0 TO RING_LAST DO
    IF uiIdx < uiUsed AND aeRing[uiIdx] = eFind THEN
        CountOf := CountOf + 1;
    END_IF
END_FOR
