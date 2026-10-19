# Статический анализ

Находки `iec_checker` по `build/assembled/` (и `st_lint` по `src/`, `tests/`), которые не
исправлены в коде, — с обоснованием. Исправленные находки сюда не пишутся. Здесь же — итог
проверки компиляции RuSTy. Разделы ниже — по командам реализации (DESIGN, раздел 15) и итог
сборки контура (объединённый проект).

## Как запускается

| Инструмент | Где | Вход | Отчёт |
|---|---|---|---|
| `tools/check/st_lint.py --strict` | локально и в CI | `src/`, `tests/` | вывод в консоль, код выхода ≠ 0 при нарушениях |
| `tools/check/run_iec_checker.py --tests` | локально и в CI (обязательно): бинарник iec_checker v0.4 из релизов github.com/jubnzv/iec-checker | `build/assembled/iec-checker/` (вариант сборки `iec-checker`) | `build/iec_checker.json`, `build/iec_checker.md` |
| то же с `--docker` | CI, необязательное задание: образ `jubnzv1/iec-checker:nightly`, закреплённый по дайджесту в `ci.yml` | то же | то же, артефакт `iec-checker-nightly-reports` |
| `tools/check/run_rusty.py` | локально и в CI (необязательное задание): RuSTy `plc --check` | `build/assembled/rusty/` (вариант сборки `rusty`, `src/` и `tests/`) | `build/rusty.log`, `build/rusty.json` |

Обоснования в `tools/check/iec_checker_allow.toml` подобраны под находки v0.4 — той же версии, что в
обязательном шаге CI. Образ `nightly` разбирает больше конструкций и может находить иначе: если
находка есть только в одной версии — укажите это в столбце «решение». Интеграционный тест
`tools/tests/test_run_iec_checker.py::test_integration_repository_sources` проверяет, что каждое
обоснование используется: после правок кода уберите устаревшие записи.

## Последний прогон (объединённый проект)

| Дата | Инструмент | Вход | Итог |
|---|---|---|---|
| 2026-10-20 | `st_lint --strict` | `src/`, `tests/` (1033 файла, после исправления ПИД при выбытии ведущего) | 0 ошибок, 0 предупреждений |
| 2026-10-20 | `run_iec_checker.py --tests` (iec_checker 0.4, Windows, локально) | 121 объект `src/` и `tests/` | ошибок разбора нет; необоснованных 0; обоснованных 4510 (19.10.2026, после правок по ревью кода, — 4434), артефактов сборки 232 |
| 2026-10-19 | `run_rusty.py` (RuSTy 1.0.6, `plc --check`, Windows, локально) | 35 файлов `build/assembled/rusty/`, исключено 87 (`rusty_exclude.txt`, по разделам команд) | 0 ошибок; предупреждения E040 (значение перечисления в инициализаторе) |
| — | iec_checker 0.4 (CI, Linux) | 121 объект `src/` и `tests/` | _перенести из отчёта CI_ |
| — | iec_checker `nightly` (CI, необязательно) | то же | _перенести из отчёта CI_ |

## Находки, общие для всего проекта

| Правило | Файл | Находка | Решение / обоснование |
|---|---|---|---|
| PLCOPEN-CP3 | все POU `src/` и `tests/` | «Variable … shall be initialized before being used» для входов, выходов и локальных переменных без явного начального значения | Обосновано общими записями (`src/*`, `tests/*`). В CODESYS, как и по МЭК 61131-3, переменная без явного начального значения получает значение по умолчанию своего типа; вариант сборки `iec-checker` убирает неконстантные начальные значения, поэтому находка есть и для них; часть находок — на копиях переменных в методах, которые сборка понижает до функций |
| PLCOPEN-CP9 | наборы тестов `tests/*` | «Code is too complex» | Обосновано общей записью: наборы — последовательные вызовы без ветвлений (классическая сложность — 1), подсчёт iec_checker 0.4 завышен |
| UnusedVariable | константы наборов `tests/POUs/*_Test/*_Test.decl.st` (UPPER_SNAKE_CASE) | «Found unused local variable» | Артефакт понижения: константы набора используются в методах-тестах, которые сборка выносит в отдельные функции |

Остальные находки и их обоснования — в разделах команд ниже.

## RuSTy (`plc --check`)

Компилятор RuSTy 1.0.6 проверяет синтаксис и типы варианта сборки `rusty` (`src/` и `tests/`); компоновки
нет. Пространства имён `coUnit.`/`CfUnit.` убираются, объявления coUnit и блоков CODESYS Standard берутся
из прокладок `tools/check/rusty_shims/` (сигнатуры — по исследованию API, с CODESYS не сверялись).
Объявлений plc-process-lib (`PL.*`), CAA File и SysTimeRtc в репозитории нет: файлы, которые к ним
обращаются, и зависящие от них заносятся в `tools/check/rusty_exclude.txt` с причиной (по разделам
команд); прогоны с библиотекой в прокладках — ручной шаг, итоги — в разделах команд и «Сборка контура».

## Ограничения разборщика

Конструкции CODESYS, которые iec_checker 0.4 не разбирает, — и что с ними делает вариант сборки
`iec-checker` (подробно — [LAYOUT.md](LAYOUT.md#собранный-текст-buildassembled) и `tools/README.md`):

| Конструкция | Где в проекте | Как обходится |
|---|---|---|
| метки `CASE` вида `E_ControlAct.Stepped` | `FB_StationCore`, ФБ станции и модели | сборка заменяет метки целыми значениями перечисления; метки по константам ФБ и перечислениям библиотеки заменены в коде на `IF … ELSIF` (раздел К3) |
| неконстантные начальные значения (`:= GVL_Const.ИМЯ`, значения перечислений) | DUT станции и имитации, `GVL_StationDefaults` | сборка убирает начальное значение (отсюда часть находок CP3) |
| `VAR_GLOBAL` вне `CONFIGURATION`, прагмы `{attribute …}` | все GVL, перечисления | сборка понижает |
| методы и свойства внутри `FUNCTION_BLOCK`, `IMPLEMENTS`, `EXTENDS` | ФБ станции, журнала, модели, подменные объекты и наборы тестов | сборка выносит методы в функции `<ФБ>__<метод>` — анализ методов приблизительный |

## Логика станции

ФБ станции (`src/POUs/Station/`), их тесты (`tests/POUs/Station/`) и подменные объекты
(`tests/POUs/Fakes/`). Обоснования — раздел «Логика станции» в `tools/check/iec_checker_allow.toml`.

| Дата | Инструмент | Вход | Итог |
|---|---|---|---|
| 2026-10-19 | `st_lint --strict` | `src/`, `tests/` (561 файл) | 0 ошибок, 0 предупреждений |
| 2026-10-19 | `run_iec_checker.py --tests` (iec_checker 0.4, Windows, локально) | 57 объектов `src/` и `tests/` | ошибок разбора нет; необоснованных 0; обоснованных 2308, артефактов сборки 92. Логика станции: CP3 — 433, L17 — 245, UnusedVariable — 60, CP9 — 29; тесты станции и подменные объекты: CP3 — 1019, CP9 — 303, UnusedVariable — 110, L17 — 9 |
| 2026-10-19 | `run_rusty.py` (RuSTy 1.0.6) | — | не применяется: прокладок `rusty_shims/` для типов plc-process-lib (`PL.*`) нет, `IMPLEMENTS PL.I_MotorVfd` RuSTy не разбирает (E007); решение об исключении файлов, использующих `PL`, — общее для проекта (так поступила и модель) |

| Правило | Файл | Находка | Решение / обоснование |
|---|---|---|---|
| PLCOPEN-CP3 | все POU станции и тесты | «Variable … shall be initialized before being used» | Обосновано общей записью: значения по умолчанию типов (МЭК 61131-3, CODESYS); понижение убирает неконстантные начальные значения |
| PLCOPEN-L17 | ФБ станции, помощники тестов, подменные объекты | «Each IF instruction should have an ELSE clause» | Обосновано: у условия нет действия «иначе» — бит слова состояния, событие по смене, фиксация, переход автомата только при условии; пустая ветвь `ELSE` — шум |
| PLCOPEN-CP9 | тела ФБ станции (`FB_StationCore` — 390, `FB_PumpRotation` — 247, `FB_Protections` — 155 по счёту iec_checker) и их методы | «Code is too complex» | Обосновано: тела — нормативные последовательности шагов DESIGN 6.x и 7 с пронумерованными шагами; деление на методы спрятало бы порядок цикла. iec_checker 0.4 считает каждое логическое выражение и каждую ветвь вложенных циклов. Ветви покрыты 173 юнит-тестами (`cds.py test`). Тесты — общая запись: ветвлений в наборах нет |
| UnusedVariable | ФБ станции: экземпляры `fb*`, `afb*`, структуры `st*` (`stCfg`, `stRetain`, `stOld`, `stNew`, `stSts`, `stPidCfg`) | «Found unused local variable» | Ложное срабатывание: экземпляры используются вызовом, методами и чтением выходов, структуры — обращением к полям |
| UnusedVariable | `FB_StationCore`: `uiExportLines`, `udiExportError` | то же | Ложное срабатывание: аргументы вложенного вызова (`rValue := UINT_TO_REAL(uiExportLines)` в вызове `LogEvent`) |
| UnusedVariable | тесты станции: `fbDut*`, `afbPump`, `stSts`, `uBits`; входы помощников `uiSteps` | то же | Ложное срабатывание: вызов, чтение выходов, поля структур и объединений, граница цикла `FOR … TO uiSteps` |
| UnusedVariable | подменные объекты: поля-входы `FB_FakeMotorVfd`, кольцо `FB_FakeEventSink`, `uiIndex` метода `GetAlarm` | то же | Артефакт понижения: поля читают аксессоры свойств и методы, вынесенные сборкой в отдельные функции (тело ФБ пустое); `uiIndex` намеренно не используется — тревог у подменного насоса нет |

Исправлено по итогам прогона: в двух тестах `FB_Ventilation_Test` объявленная, но не использованная
переменная шага (настоящая находка `UnusedVariable`).

## Сгенерированный слой, полевой слой, журнал (К3)

Прогоны 19.10.2026 по состоянию ветки К3 (без объектов логики станции и модели):

| Инструмент | Вход | Итог |
|---|---|---|
| `st_lint --strict` | `src/`, `tests/` (222 файла) | 0 ошибок, 0 предупреждений; STL003 выключено только для сгенерированного `GVL_Persist.pvl.st` (ASSUMPTIONS К3-01) |
| `run_iec_checker.py --tests` (iec_checker 0.4) | 44 объекта `src/` и `tests/` | ошибок разбора нет; необоснованных 0; обоснованных 871 (808 до проверочных тестов и исправлений 19.10.2026: новые находки — те же правила CP3, L17, CP9, UnusedVariable в новых тестах и в `PRG_Slow`) |
| `run_rusty.py` (RuSTy 1.0.6) | 12 файлов, исключено 33 (`rusty_exclude.txt`, раздел К3) | 0 ошибок |
| `run_rusty.py` с прокладками: сборка `assembled/rusty` plc-process-lib 1.0.0, CAA File (`Open`, `Write`, `Read`, `Close`, `MODE`, `ERROR`) и `SysTimeRtcHighResGet` по сигнатурам, `--strip-namespace PL --strip-namespace FILE` | все файлы К3, кроме `GVL_Persist`, `GVL_CfgProject`, `PRG_ApplyProjectCfg`, `PRG_Devices` | 0 ошибок; предупреждения E049 (`PRG_FieldOut` обращается к `PRG_FieldIn.fbVfdP10n` — в CODESYS допустимо), E067 (неявное сужение литералов и `SIZEOF`), E040, E091 |

| Правило | Файл | Решение / обоснование |
|---|---|---|
| PLCOPEN-CP9 | `src/POUs/Generated/*` | Сгенерированный код: 29 вызовов устройств и присваивания по одному на строку; сложность растёт с числом устройств, а не с логикой |
| PLCOPEN-CP9 | `PRG_FieldIn` | Линейное копирование выходов трёх адаптеров ПЧ в `GVL_IO` (имена у насосов свои), одно ветвление |
| PLCOPEN-CP9 | `FB_AlarmSummary`, `BuildView`, `F_UtcToIso`, `FB_EventLog` | Классическая сложность — 12, 12, 4, 3; iec_checker 0.4 считает завышенно |
| PLCOPEN-L17 | `src/POUs/Log/*`, `src/POUs/Field/*`, `PRG_Devices`, тесты `tests/POUs/Log/*` | Действия «иначе» нет: условие не выполнено — состояние не меняется (первый цикл прошёл, кольцо не полно, команда не пришла); в многоцикловых тестах — проверки по завершении |
| UnusedVariable | `src/POUs/Field/*`, `src/POUs/Log/*`, тесты | Артефакт понижения и ложные срабатывания: переменные ФБ используются в методах (сборка выносит их в функции), структуры — обращениями к полям, экземпляры — вызовами и методами, константы — аргументами вложенных `CONCAT` |

Исправлено по итогам прогона: метки `CASE` по константам ФБ и по перечислению библиотеки
(`FILE.MODE`, `PL.E_DeviceType`) заменены на `IF … ELSIF` и константу `MODE_WRITE` (iec_checker 0.4 не
разбирал их — ParserError); цепочка `GetAlarm(...).State` в тестах — через переменную интерфейса;
длина строковой константы `CRLF` — без явной длины (ложное OutOfBounds на `$R$N`); сравнения
`aitfSource[i] <> 0` — через переменную интерфейса (RuSTy E031: замена R1 не видит элемент массива).

## Модель объекта и часы контура (К2)

Объекты: `src/POUs/Model/*`, `src/POUs/Time/FB_ScaledClock`, `src/DUTs/Sim/*`, `src/GVLs/Sim/*`, раздел «Модель»
`GVL_Const`, наборы `tests/POUs/Model/*`, `tests/GVLs/GVL_TestsModel`. Обоснования — раздел «Модель, имитация,
часы контура» в конце `tools/check/iec_checker_allow.toml`.

| Дата | Инструмент | Вход | Итог |
|---|---|---|---|
| 2026-10-19 | `st_lint --strict` | `src/`, `tests/` (293 файла вместе с примером шаблона) | 0 ошибок, 0 предупреждений |
| 2026-10-19 | `run_iec_checker.py --tests` (iec_checker 0.4, Windows) | 44 объекта `src/` и `tests/` | ошибок разбора нет; необоснованных 0; по объектам модели: `src/` — CP3 244, L17 68, UnusedVariable 28, CP9 17 обоснованы, артефактов 61; `tests/` — CP3 265, UnusedVariable 153, CP9 128, L17 1 обоснованы, артефактов 18 |
| 2026-10-19 | `run_rusty.py` (RuSTy 1.0.6) | 26 файлов `build/assembled/rusty/`, исключено 19 (`rusty_exclude.txt`) | 0 ошибок |
| 2026-10-19 | `run_rusty.py --strip-namespace coUnit --strip-namespace CfUnit --strip-namespace PL` с прокладками шаблона и сборкой `assembled/rusty` plc-process-lib 1.0.0 (`I_TimeSource`, `FB_SystemTime`, `FB_FakeTime`, `FB_Delay`, `F_IsFinite`, `F_LTimeToSec`, `F_TimeToSec`, `F_RateLimit`, `U_RealBits`, `GVL_Const`), без исключений | все 45 файлов | 0 ошибок; 2 предупреждения E067 в `FB_InflowProfile` (`TRUNC` в RuSTy возвращает `LINT`, в CODESYS — `DINT`) |
| 2026-10-19 | повтор после проверки модели (исправления M14–M18, тесты мутационной проверки): `st_lint --strict` | `src/`, `tests/` (315 файлов) | 0 ошибок, 0 предупреждений |
| 2026-10-19 | то же: `run_iec_checker.py --tests` | 44 объекта `src/` и `tests/` | ошибок разбора нет; необоснованных 0, обоснованных 1190, артефактов сборки 93 (новые `UnusedVariable` для `uBitsA`/`uBitsB` в `F_FaultInjEqual` — обоснование дополнено) |
| 2026-10-19 | то же: `run_rusty.py` | 25 файлов, исключено 20 (`F_FaultInjEqual` теперь обращается к `PL.U_RealBits`) | 0 ошибок |
| 2026-10-19 | то же: `run_rusty.py` с объявлениями plc-process-lib в прокладках, без исключений | все 45 файлов | 0 ошибок; те же 2 предупреждения E067 в `FB_InflowProfile` |

| Правило | Файл | Находка | Решение / обоснование |
|---|---|---|---|
| PLCOPEN-CP3 | все POU модели и наборы | «Variable … shall be initialized before being used» | Обосновано общими записями шаблона (`src/*`, `tests/*`): значения по умолчанию типов; сборка убирает неконстантные начальные значения (`:= T#10S`, `:= -1.0` в `STRUCT`) |
| PLCOPEN-CP9 | `FB_PlantModel` (iec_checker: 171), `FB_VfdSim` (116), `FB_StormGenerator` (39), `FB_HydraulicSolver` (22), `FB_AnalogSensorSim` (21), `FB_TankModel` (18), `FB_InflowProfile`, `PRG_PlantModel` (число операторов) | «Code is too complex» | Обосновано. Тела — нормативная последовательность шагов DESIGN 11.1–11.2 с номерами шагов в комментариях; классическая цикломатическая сложность (точки ветвления `IF`/`ELSIF`/`FOR`/метки `CASE` + 1, без логических операций): `FB_PlantModel` — 28, `FB_VfdSim` — 27, `FB_AnalogSensorSim` и `FB_StormGenerator` — 10, `FB_HydraulicSolver` — 7, `Solve` — 7, `FB_TankModel` — 6, `FB_InflowProfile` — 5, остальные тела и методы — ≤ 4; `PRG_PlantModel` — 2 (линейное копирование `ST_PlantIo` в `GVL_IO`, 75 операторов). Деление на методы спрятало бы порядок шагов, а методы не должны обращаться к `VAR_IN_OUT` (R2 контракта библиотеки) |
| PLCOPEN-L17 | `src/POUs/Model/*`, `FB_ScaledClock` | «Each IF instruction should have an ELSE clause» | Обосновано: команда не пришла, причины аварии нет, шаг времени 0, поле инъекции не изменилось, базы часов уже заданы — действия «иначе» нет |
| UnusedVariable | `FB_PlantModel` (`stCfg`, `stCmd`, `stIo`, `stSts`, экземпляры ФБ модели), `F_FaultInjEqual` (`stA`, `stB`), `F_PumpCurrent` (`stPump`), `FB_StormGenerator` (`stManual`), `FB_VfdSim` (`fbBoot`, `fbWatchdog`), `PRG_PlantModel` (`fbPlant`) | «Found unused local variable» | Ложное срабатывание iec_checker 0.4: структуры используются обращениями к полям, экземпляры ФБ — вызовом, методами и чтением выходов |
| UnusedVariable | `FB_ScaledClock` (все переменные), `FB_HydraulicSolver` (`arK`), `FB_StormGenerator` (`dwState`) | то же | Переменные используются только в методах; понижение выносит методы в отдельные функции, в теле ФБ их не видно (тело `FB_ScaledClock` пустое) |
| UnusedVariable | наборы `tests/POUs/Model/*`: `fbDut`, `fbClock`, `fbOther`, `fbFresh`, `fbStopped`, `fbA`, `fbB`, `stCfg`, `stPump`, `stNoFaults`, `uBits` | то же | Ложное срабатывание, как в `src/`; настоящие неиспользуемые переменные в наборах убраны (переменная объявляется, только если тест её использует) |
| PLCOPEN-L17 | `FB_StormGenerator_Test.StormCrossingMidnightContinues` | то же | Поиск ливня суток 21 в списке: на остальных элементах делать нечего |

RuSTy: объявлений plc-process-lib в репозитории нет (библиотека подключается в CODESYS по `config.json`),
поэтому в обязательном варианте исключены файлы, которые обращаются к `PL.*` или объявляют экземпляры
исключённых ФБ (как в проекте 10 портфолио; ASSUMPTIONS M12). Проверяются типы и GVL имитации, `GVL_Const`,
`F_Xorshift32`, `F_FloatContact` (`F_FaultInjEqual` сравнивает поля `REAL` через `PL.U_RealBits` — исключён). Полная проверка с библиотекой в прокладках (строка 4
таблицы) — ручной шаг: прокладки шаблона принадлежат шаблону (`tools/check/rusty_shims/*`), а библиотеку
в них копировать нельзя.

## Сборка контура (объединённый проект)

Объекты: `src/POUs/Station/PRG_Station`, правки `PRG_FieldIn`, `GVL_Sim` (`xIoReady`), перекрытие шаблона
`PRG_Devices`, ядро станции с энергонезависимой копией уставок, набор
`tests/POUs/Field/FB_PlcStartAdoption_Test`, новые тесты `FB_StationCore_Test`. Обоснования — раздел
«Интеграция веток» в конце `tools/check/iec_checker_allow.toml` и общие записи команд. Итоги прогонов по
всему проекту — таблица «Последний прогон» выше.

| Правило | Файл | Находка | Решение / обоснование |
|---|---|---|---|
| PLCOPEN-CP3 | `PRG_Station` (9), `PRG_FieldIn`, `GVL_Sim`, `FB_PlcStartAdoption_Test` (17) | как выше | Обосновано общими записями `src/*`, `tests/*` |
| PLCOPEN-L17 | `PRG_Station` (9): выход до действительных входов, номера тревог, сброс и квитирование, выгрузка, аудит после первого вызова устройств; `PRG_Devices` (выход перекрытия шаблона); `PRG_FieldIn` (`xIoReady`) | «Each IF instruction should have an ELSE clause» | Обосновано записями `src/POUs/Station/*`, `src/POUs/Generated/*`, `src/POUs/Field/*`: у условия нет действия «иначе» |
| PLCOPEN-CP9 | `PRG_Station` (2), `FB_PlcStartAdoption_Test` (4) | «Code is too complex» (число операторов) | Обосновано: `PRG_Station` — привязка ядра без логики (DESIGN 7), тест — последовательность вызовов и проверок |
| UnusedVariable | `PRG_Station`: `fbCore` | «Found unused local variable» | Ложное срабатывание (запись `src/POUs/Station/*`): экземпляр используется вызовом и чтением выходов |
| UnusedVariable | `FB_PlcStartAdoption_Test`: `fbES301`, `fbP101` (`VAR_INST` методов) | то же | Ложное срабатывание (запись «Интеграция веток»): экземпляры устройств библиотеки используются вызовом и чтением выходов |

Исправлено по итогам прогона: проверка шага в цикле теста подхвата (`IF uiStep = 1`) заменена первым
вызовом до цикла (находка L17 без обоснования).

RuSTy: файлы логики станции и сборки контура исключены (34 файла: обращаются к `PL.*`, наборы — к исключённым
ФБ), как у К2 и К3 (ASSUMPTIONS И8). Ручной прогон с библиотекой в прокладках (сборка `assembled/rusty`
plc-process-lib 1.0.0 и прокладки шаблона, `--strip-namespace PL`, исключены только файлы, которым нужны
прокладки CAA File и SysTimeRtc, и `GVL_CfgProject`, `GVL_Persist`, `PRG_Devices`, `PRG_ApplyProjectCfg`,
`PRG_Station` — одинаковые имена Cfg, раздел К3): файлы станции дают ошибки только там, где RuSTy 1.0.6 не
понимает конструкции, которые компилирует CODESYS (0 ошибок, 0 предупреждений `cds.py check --tests`):

| Ошибка RuSTy | Где | Причина |
|---|---|---|
| E031 «types __FATPOINTER and DINT are incompatible» | `aitfPump[i] <> 0` в `FB_Ats`, `FB_LevelControlPid`, `FB_PumpRotation`, `FB_StationCore`, `FB_StationMode` | сравнение элемента массива интерфейсов с 0 (так же у К3; там переписано через переменную интерфейса) |
| E032/E089 «this POU takes 0 arguments» | вызовы помощников `Cycle`, `Step` в наборах станции | вызов метода с `VAR_IN_OUT` экземпляром ФБ |
| E048 `WORD_TO_REAL` | `FB_StationCore` | нет преобразования в прокладке совместимости шаблона |
| E048 | `FB_PlcStartAdoption_Test`, `FB_AlarmSummary`, `FB_DeviceAudit_Test` | ссылки на исключённые `GVL_CfgProject`, `F_UtcNowMs`, `FB_EventLog` |
