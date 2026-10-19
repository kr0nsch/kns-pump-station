// Назначение: REAL (IEEE 754) из двух регистров Modbus: старшее и младшее слово. Порядок слов задаёт
//             вызывающий: TT403 — старшее первым (HL, перечень сигналов), модули ОВЕН Mx210 — младшее
//             первым (F_Mx210AiToMa).
// Автор:      kr0nsch
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, раздел 8.4; targets/plc210/README.md
FUNCTION F_WordsToReal : REAL
VAR_INPUT
    wHi : WORD;     // старшие 16 бит (знак, экспонента, старшая часть мантиссы)
    wLo : WORD;     // младшие 16 бит мантиссы
END_VAR
VAR
    uBits : PL.U_RealBits;  // те же 32 бита как REAL
END_VAR
