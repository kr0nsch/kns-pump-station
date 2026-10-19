// Назначение: сравнение двух наборов инъекций ST_FaultInjection поле за полем (структуры в CODESYS
//             оператором «=» не сравниваются). FB_PlantModel по нему считает изменения инъекций
//             (stSimSts.udiFaultSeq → событие журнала 101021). Новое поле ST_FaultInjection добавляется
//             и сюда — тест FaultSeqCountsChanges меняет каждое поле.
// Автор:      <ИМЯ ФАМИЛИЯ>
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, разделы 3.3, 11.1
FUNCTION F_FaultInjEqual : BOOL
VAR_IN_OUT CONSTANT
    stA : ST_FaultInjection;
    stB : ST_FaultInjection;
END_VAR
VAR
    uiI : UINT;             // индекс насоса или датчика
END_VAR
