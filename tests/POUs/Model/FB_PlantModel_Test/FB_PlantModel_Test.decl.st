// Назначение: набор coUnit для FB_PlantModel (и FB_AnalogSensorSim, F_FloatContact, F_FaultInjEqual) — модель
//             объекта целиком: начальное состояние входов ПЛК, баланс массы, установившийся режим против эталона,
//             согласованность при разном шаге (ускорении), команды модели и сброс импульсов, ливень по команде,
//             отказы датчиков 4–20 мА, поплавки, вентилятор, инъекции насосов и счётчик их изменений, кнопки,
//             сухой ход и засор, осушенный приёмок, «время назад», время суток, предел шага. Время —
//             PL.FB_FakeTime; ожидаемые значения — эталон tools_project/plant_reference.py.
// Автор:      <ИМЯ ФАМИЛИЯ>
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, разделы 11.3, 14.1
FUNCTION_BLOCK FB_PlantModel_Test EXTENDS coUnit.FB_TestSuite
VAR CONSTANT
    T_STEP : TIME := T#1S;            // шаг модели в тесте (k = 50 при цикле 20 мс)
    T_FINE : TIME := T#100MS;         // мелкий шаг
    UI_FREF_50HZ : UINT := 5000;
    UI_FREF_87PCT : UINT := 4350;     // 43,5 Гц
    R_EPS_MA : REAL := 2.0E-3;        // допуск тока датчика, мА
    R_EPS_M : REAL := 1.0E-4;         // допуск уровня, м
    UI_FAULT_FIELDS : UDINT := 23;    // полей ST_FaultInjection в проверке счётчика
    DW_NAN : DWORD := 16#7FC00000;
END_VAR
