// 04 §19.3, DESIGN 3.1: ST_StationSts — только 16- и 32-битные поля, 72 байта (раскладка для OPC UA и MQTT)
METHOD PRIVATE StationStsSizeIs72
VAR
    stSts : ST_StationSts;              // проверяемая структура
END_VAR
