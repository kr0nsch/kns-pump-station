aeRing[uiHead] := eEvent;
arRing[uiHead] := rValue;
IF uiHead >= RING_LAST THEN
    uiHead := 0;
ELSE
    uiHead := uiHead + 1;
END_IF
udiCount := udiCount + 1;
eLastEvent := eEvent;
rLastValue := rValue;
LogEvent := TRUE;
