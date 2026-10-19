// Назначение: подменный насос с ПЧ для юнит-тестов станции (PL.I_MotorVfd без устройства и модели).
//             Состояние задаёт тест полями-входами; Available и ReadyToStart выводятся из них как у
//             устройства (Auto, нет отказа; ReadyToStart — ещё стоит и xReady). Запросы RequestMode,
//             Reset, AckAll считаются; при xFollowRequests RequestMode сразу меняет режим (Local
//             остаётся Local — меняется запомненный режим, API 2.2). Тревог нет (GetAlarm → 0).
// Автор:      kr0nsch
// Версия:     0.1.0
// Документ:   docs/DESIGN.md, раздел 6.14
FUNCTION_BLOCK FB_FakeMotorVfd IMPLEMENTS PL.I_MotorVfd
VAR_INPUT
    xAvailable           : BOOL := TRUE;    // доступность без учёта режима и отказа
    xRunning             : BOOL;            // работает по ОС
    xReady               : BOOL := TRUE;    // нет паузы tMinStop и лимита пусков
    eMode                : PL.E_DeviceMode := PL.E_DeviceMode.Auto;
    xFault               : BOOL;            // отказ (Status = Failure)
    eStatus              : PL.E_Ne107Status := PL.E_Ne107Status.Good;   // NE 107 без отказа (ТО — MaintenanceRequired)
    udiRunSeconds        : UDINT;           // наработка, с
    udiCurrentRunSeconds : UDINT;           // текущая непрерывная работа, с
    udiStarts            : UDINT;           // пусков всего
    rSpeedRef            : REAL;            // задание на ПЧ, %
    rSpeedAct            : REAL;            // фактическая скорость, %
    xSpeedAuto           : BOOL;            // SpeedAutoActive
    xFollowRequests      : BOOL;            // RequestMode меняет eMode сразу
END_VAR
VAR_OUTPUT
    uiRequestModeCalls : UINT;              // вызовов RequestMode
    eLastModeRequest   : PL.E_DeviceMode;   // режим последнего RequestMode
    eRememberedMode    : PL.E_DeviceMode;   // запомненный дистанционный режим (запрос в Local)
    uiResetCalls       : UINT;              // вызовов Reset
    uiAckAllCalls      : UINT;              // вызовов AckAll
END_VAR
