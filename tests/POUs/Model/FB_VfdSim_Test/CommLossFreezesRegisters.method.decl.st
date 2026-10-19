// Потеря связи на 25 Гц: xCommOk = FALSE, регистры STW и FACT замирают; новое задание не доходит
// (частота 25 Гц); стоп по проводу работает (через 2 с — 15 Гц), а FACT по-прежнему 2500.
METHOD PRIVATE CommLossFreezesRegisters
VAR
    fbTime : PL.FB_FakeTime;    // подменное время
    fbDut : FB_VfdSim;          // проверяемая модель ПЧ
    uiI : UINT;
END_VAR
