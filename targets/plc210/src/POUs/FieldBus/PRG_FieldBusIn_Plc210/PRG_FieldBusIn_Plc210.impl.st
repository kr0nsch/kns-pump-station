// В этой сборке имитация запрещена (GVL_Const.SIM_ALLOWED = FALSE); проверка — на случай ручной правки
IF GVL_Sim.xSimulation THEN
    RETURN;
END_IF

// 1. Встроенные AI1…AI4 ПЛК210-14 → A1.1…A1.4 (NaN при ошибке канала)
GVL_IO.rLT101_mA := F_OwenAiToMa(rValue_pct := arAiValue_pct[1], usiStatus := ausiAiStatus[1]);
GVL_IO.rPT201_mA := F_OwenAiToMa(rValue_pct := arAiValue_pct[2], usiStatus := ausiAiStatus[2]);
GVL_IO.rFT202_mA := F_OwenAiToMa(rValue_pct := arAiValue_pct[3], usiStatus := ausiAiStatus[3]);
GVL_IO.rAT401_mA := F_OwenAiToMa(rValue_pct := arAiValue_pct[4], usiStatus := ausiAiStatus[4]);

// 2. МВ210-101, вход 1 → A1.5 (AT402); без связи с модулем — NaN, как обрыв датчика
rAT402_mA := F_Mx210AiToMa(wLo := awMx101Ai1[GVL_ConstPlc210.MB_MX_AI_LO],
                           wHi := awMx101Ai1[GVL_ConstPlc210.MB_MX_AI_HI]);
IF MV210_101.xError THEN
    uNan.dwValue := GVL_Const.REAL_QNAN_BITS;
    rAT402_mA := uNan.rValue;
END_IF
GVL_IO.rAT402_mA := rAT402_mA;

// 3. ПЧ Н1…Н3, чтение: слово состояния, фактическая частота, ток, код аварии
GVL_IO.wP101_STW := awP101Rd[GVL_ConstPlc210.MB_VFD_RD_STW];
GVL_IO.uiP101_FACT := WORD_TO_UINT(awP101Rd[GVL_ConstPlc210.MB_VFD_RD_FACT]);
GVL_IO.uiIT111 := WORD_TO_UINT(awP101Rd[GVL_ConstPlc210.MB_VFD_RD_IT]);
GVL_IO.uiP101_FCODE := WORD_TO_UINT(awP101Rd[GVL_ConstPlc210.MB_VFD_RD_FCODE]);

GVL_IO.wP102_STW := awP102Rd[GVL_ConstPlc210.MB_VFD_RD_STW];
GVL_IO.uiP102_FACT := WORD_TO_UINT(awP102Rd[GVL_ConstPlc210.MB_VFD_RD_FACT]);
GVL_IO.uiIT121 := WORD_TO_UINT(awP102Rd[GVL_ConstPlc210.MB_VFD_RD_IT]);
GVL_IO.uiP102_FCODE := WORD_TO_UINT(awP102Rd[GVL_ConstPlc210.MB_VFD_RD_FCODE]);

GVL_IO.wP103_STW := awP103Rd[GVL_ConstPlc210.MB_VFD_RD_STW];
GVL_IO.uiP103_FACT := WORD_TO_UINT(awP103Rd[GVL_ConstPlc210.MB_VFD_RD_FACT]);
GVL_IO.uiIT131 := WORD_TO_UINT(awP103Rd[GVL_ConstPlc210.MB_VFD_RD_IT]);
GVL_IO.uiP103_FCODE := WORD_TO_UINT(awP103Rd[GVL_ConstPlc210.MB_VFD_RD_FCODE]);

// 4. TT403: REAL из двух регистров, старшее слово первым; неконечное значение PL.FB_AnalogInput отбросит
GVL_IO.rTT403 := F_WordsToReal(wHi := awTT403Rd[GVL_ConstPlc210.MB_TT403_HI],
                               wLo := awTT403Rd[GVL_ConstPlc210.MB_TT403_LO]);

// 5. Признаки обмена: xError экземпляра слейва Modbus (диагностика драйвера IoDrvModbus из пакета ОВЕН)
GVL_IO.xMbOk_RS485_1_S1 := NOT P101.xError;
GVL_IO.xMbOk_RS485_1_S2 := NOT P102.xError;
GVL_IO.xMbOk_RS485_1_S3 := NOT P103.xError;
GVL_IO.xMbOk_RS485_2_S10 := NOT TT403.xError;
