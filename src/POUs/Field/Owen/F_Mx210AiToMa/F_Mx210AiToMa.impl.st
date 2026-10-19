IF SHR(wHi, GVL_Const.MB_BYTE_BITS) >= GVL_Const.MX210_AI_ERR_MIN THEN
    uBits.dwValue := GVL_Const.REAL_QNAN_BITS;
    F_Mx210AiToMa := uBits.rValue;
ELSE
    F_Mx210AiToMa := PL.GVL_Const.MA_ZERO
                     + F_WordsToReal(wHi := wHi, wLo := wLo) * PL.GVL_Const.MA_SPAN / PL.GVL_Const.PCT_FULL;
END_IF
