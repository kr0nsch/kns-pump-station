// Назначение: экземпляры наборов тестов логики станции (команда «логика станции», DESIGN 14.1).
//             Объявление регистрирует набор в coUnit; {attribute 'linkalways'} обязателен — без него
//             компилятор выбросит GVL, на которую никто не ссылается, и наборы молча пропадут.
// Автор:      <ИМЯ ФАМИЛИЯ>
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, раздел 14.1
{attribute 'qualified_only'}
{attribute 'linkalways'}
VAR_GLOBAL
    fbStationModeTest          : FB_StationMode_Test;           // 6.1
    fbControlSelectorTest      : FB_ControlSelector_Test;       // 6.2
    fbLevelControlSteppedTest  : FB_LevelControlStepped_Test;   // 6.3
    fbLevelControlPidTest      : FB_LevelControlPid_Test;       // 6.4
    fbPumpRotationTest         : FB_PumpRotation_Test;          // 6.5
    fbAtsTest                  : FB_Ats_Test;                   // 6.6
    fbProtectionsTest          : FB_Protections_Test;           // 6.7
    fbPumpProtectionTest       : FB_PumpProtection_Test;        // 6.8
    fbPowerRestoreTest         : FB_PowerRestore_Test;          // 6.9
    fbVentilationTest          : FB_Ventilation_Test;           // 6.10
    fbStationAlarmsTest        : FB_StationAlarms_Test;         // 6.11
    fbAnnunciatorTest          : FB_Annunciator_Test;           // 6.12
    fbStationCfgCheckTest      : FB_F_StationCfgCheck_Test;     // 6.13
    fbStationCoreTest          : FB_StationCore_Test;           // 6.15, раздел 7
END_VAR
