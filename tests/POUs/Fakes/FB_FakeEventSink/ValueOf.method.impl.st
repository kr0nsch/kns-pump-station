ValueOf := -1.0;
xFound := FALSE;
uiIdx := uiHead;
FOR uiStep := 0 TO RING_LAST DO
    IF uiIdx = 0 THEN
        uiIdx := RING_LAST;
    ELSE
        uiIdx := uiIdx - 1;
    END_IF
    IF NOT xFound AND UINT_TO_UDINT(uiStep) < udiCount AND aeRing[uiIdx] = eFind THEN
        ValueOf := arRing[uiIdx];
        xFound := TRUE;
    END_IF
END_FOR
