pChar := ADR(sText);
FOR iI := 1 TO LEN(sText) DO
    IF udiLen < READ_BUF_LEN THEN
        abBuf[udiLen] := pChar^;
        udiLen := udiLen + 1;
    END_IF
    pChar := pChar + 1;
END_FOR
