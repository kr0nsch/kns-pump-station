// Дописать ASCII-байты строки в буфер ожидаемого содержимого
METHOD PRIVATE AppendExpected
VAR_INPUT
    sText : STRING(GVL_Const.LOG_CSV_LINE_LEN);
END_VAR
VAR_IN_OUT
    abBuf  : ARRAY[0..READ_BUF_LEN - 1] OF BYTE;
    udiLen : UDINT;
END_VAR
VAR
    pChar : POINTER TO BYTE;        // очередной символ строки
    iI    : INT;                    // номер символа
END_VAR
