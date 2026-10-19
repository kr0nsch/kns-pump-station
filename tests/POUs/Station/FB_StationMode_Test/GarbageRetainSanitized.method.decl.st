// Правило L4 контракта: мусор в retain (режим 7, способ 0) заменяется «Ручным» и «Ступенчатым» сравнениями и
// записывается обратно
METHOD PRIVATE GarbageRetainSanitized
VAR
    fbDut    : FB_StationMode;                     // ФБ под тестом
    afbPump  : ARRAY[1..3] OF FB_FakeMotorVfd;     // подменные насосы
    fbSink   : FB_FakeEventSink;                   // подменный журнал
    stRetain : ST_StationRetain;                   // энергонезависимые данные станции
    pRaw    : POINTER TO INT;                      // запись числа вне перечисления
END_VAR
