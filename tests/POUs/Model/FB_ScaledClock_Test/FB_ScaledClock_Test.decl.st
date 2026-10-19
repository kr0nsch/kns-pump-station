// Назначение: набор coUnit для FB_ScaledClock — часы контура с ускорением: совпадение с системным
//             временем при k = 1, ограничение и неконечный коэффициент, монотонность при смене k, отношение
//             интервалов k (оценка «вилкой» по системному времени, без ожидания), ручной режим.
//             Реальное время читается только в проверках, которые ничего не ждут (docs/TESTING.md библиотеки).
// Автор:      <ИМЯ ФАМИЛИЯ>
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, разделы 11.3, 14.1
FUNCTION_BLOCK FB_ScaledClock_Test EXTENDS coUnit.FB_TestSuite
VAR CONSTANT
    R_SCALE_MAX : REAL := 50.0;           // SIM_TIME_SCALE_MAX
    LR_ROUND_NS : LREAL := 2.0;           // округление LREAL → LTIME двух отметок, нс
    LT_MANUAL_START : LTIME := LTIME#2H;
    LT_MANUAL_STEP : LTIME := LTIME#1S500MS;
    LT_MANUAL_AFTER : LTIME := LTIME#2H1S500MS;
    UI_READS : UINT := 1000;              // чтений часов в проверке монотонности
    DW_NAN : DWORD := 16#7FC00000;        // тихий NaN
    DW_INF : DWORD := 16#7F800000;        // +∞
    DW_NEG_INF : DWORD := 16#FF800000;    // −∞
END_VAR
