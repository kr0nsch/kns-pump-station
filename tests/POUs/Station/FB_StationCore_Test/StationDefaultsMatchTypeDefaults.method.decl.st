// DESIGN 4.2: GVL_StationDefaults.stStationCfg совпадает с умолчаниями ST_StationCfg по всем параметрам, тревогам
// и резерву (сравнение полей — без байтов выравнивания ST_AlarmCfg); границы резерва — по константам
// STN_CFG_RESERVE_*
METHOD PRIVATE StationDefaultsMatchTypeDefaults
VAR
    fbDut   : FB_StationCore;           // метод сравнения уставок
    stDef   : ST_StationCfg;            // копия константы GVL_StationDefaults
    stType  : ST_StationCfg;            // умолчания типа
END_VAR
