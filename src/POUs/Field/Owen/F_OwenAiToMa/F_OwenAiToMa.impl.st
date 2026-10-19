IF usiStatus = GVL_Const.OWEN_AI_STATUS_OK THEN
    F_OwenAiToMa := PL.GVL_Const.MA_ZERO + rValue_pct * PL.GVL_Const.MA_SPAN / PL.GVL_Const.PCT_FULL;
ELSE
    uBits.dwValue := GVL_Const.REAL_QNAN_BITS;
    F_OwenAiToMa := uBits.rValue;
END_IF
