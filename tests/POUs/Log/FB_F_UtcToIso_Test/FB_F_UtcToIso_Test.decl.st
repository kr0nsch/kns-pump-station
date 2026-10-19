// Назначение: набор coUnit для F_UtcToIso и F_ZeroPad — метка UTC в ISO 8601 для CSV: 0 — пусто, обычная дата,
//             29 февраля високосного года, граница суток и миллисекунды, март 2100 года (не високосный).
//             Эталоны — Python datetime (UTC).
// Автор:      kr0nsch
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, разделы 9.2, 14.1
FUNCTION_BLOCK FB_F_UtcToIso_Test EXTENDS coUnit.FB_TestSuite
