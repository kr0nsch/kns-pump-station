// Назначение: экземпляры наборов тестов модели, имитации и часов (команда К2). Набор coUnit
//             регистрируется объявлением экземпляра; {attribute 'linkalways'} обязателен — иначе
//             компилятор выбросит GVL, на которую никто не ссылается, и наборы молча пропадут
//             (решение F-01 plc-process-lib, docs/TESTING.md библиотеки).
// Автор:      <ИМЯ ФАМИЛИЯ>
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, разделы 11.3, 14.1
{attribute 'qualified_only'}
{attribute 'linkalways'}
VAR_GLOBAL
    fbScaledClockTest     : FB_ScaledClock_Test;
    fbInflowProfileTest   : FB_InflowProfile_Test;
    fbStormGeneratorTest  : FB_StormGenerator_Test;
    fbTankModelTest       : FB_TankModel_Test;
    fbHydraulicSolverTest : FB_HydraulicSolver_Test;
    fbVfdSimTest          : FB_VfdSim_Test;
END_VAR
