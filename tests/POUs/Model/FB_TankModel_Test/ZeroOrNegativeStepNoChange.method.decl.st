// Шаг 0 и отрицательный шаг («время назад») не меняют уровень и время перелива.
METHOD PRIVATE ZeroOrNegativeStepNoChange
VAR
    fbDut : FB_TankModel;       // проверяемый ФБ
END_VAR
