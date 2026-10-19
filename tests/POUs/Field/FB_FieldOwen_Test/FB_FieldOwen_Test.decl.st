// Назначение: набор coUnit для функций полевого слоя ОВЕН (сборка targets/plc210): встроенный AI ПЛК210
//             (% диапазона → мА, статус ошибки → NaN), REAL из двух регистров (порядок слов), AI модуля Mx210
//             (младшее слово первым, код ошибки в старшем байте → NaN). Функции не зависят от таргета и
//             проверяются на CODESYS Control Win.
// Автор:      kr0nsch
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, раздел 8.4; targets/plc210/README.md
FUNCTION_BLOCK FB_FieldOwen_Test EXTENDS coUnit.FB_TestSuite
VAR CONSTANT
    R_EPS_MA : REAL := 1.0E-4;      // допуск сравнения тока, мА
END_VAR
