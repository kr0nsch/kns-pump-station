// Назначение: подменный журнал событий станции для юнит-тестов (I_StationEventSink): кольцо 16
//             последних событий (код и значение), счётчик всех событий, поиск по коду.
// Автор:      <ИМЯ ФАМИЛИЯ>
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, раздел 6.14
FUNCTION_BLOCK FB_FakeEventSink IMPLEMENTS I_StationEventSink
VAR CONSTANT
    RING_LAST : UINT := 15;         // кольцо 0…15: 16 последних событий
END_VAR
VAR_OUTPUT
    udiCount   : UDINT;             // событий с последнего Clear
    eLastEvent : E_StationEvent;    // последнее событие
    rLastValue : REAL;              // его значение
END_VAR
VAR
    aeRing : ARRAY[0..RING_LAST] OF E_StationEvent;   // коды событий
    arRing : ARRAY[0..RING_LAST] OF REAL;             // значения
    uiHead : UINT;                  // индекс следующей записи
END_VAR
