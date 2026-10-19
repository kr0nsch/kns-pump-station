# Статический анализ

Находки `iec_checker` по `build/assembled/` (и `st_lint` по `src/`, `tests/`), которые не
исправлены в коде, — с обоснованием. Исправленные находки сюда не пишутся. Здесь же — итог
проверки компиляции RuSTy.

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
обоснование используется: после правок примера уберите устаревшие записи.

## Последний прогон

| Дата | Инструмент | Вход | Итог |
|---|---|---|---|
| 2026-10-16 | `st_lint --strict` | `src/`, `tests/` (60 файлов) | 0 ошибок, 0 предупреждений |
| 2026-10-16 | `run_iec_checker.py` (iec_checker 0.4, Windows, локально) | 8 объектов `src/` | ошибок разбора нет; необоснованных 0; обоснованных 32: CP3 — 24, L17 — 4, CP9 — 2, UnusedVariable — 2; артефактов сборки 10 (CP3) |
| 2026-10-16 | `run_iec_checker.py --tests` (iec_checker 0.4, Windows, локально) | 11 объектов `src/` и `tests/` | ошибок разбора нет; необоснованных 0; обоснованных 100: CP3 — 49, UnusedVariable — 30, CP9 — 17, L17 — 4; артефактов сборки 10 (CP3) |
| 2026-10-16 | `run_rusty.py` (RuSTy 1.0.6, `plc --check`, Windows, локально) | 11 файлов `build/assembled/rusty/` (`src/` и `tests/` с прокладками coUnit и Standard) | 0 ошибок, 0 предупреждений; исключений в `rusty_exclude.txt` нет |
| — | iec_checker 0.4 (CI, Linux) | 11 объектов `src/` и `tests/` | _перенести из отчёта CI_ |
| — | iec_checker `nightly` (CI, необязательно) | то же | _перенести из отчёта CI_ |

## Находки

| Правило | Файл | Находка | Решение / обоснование |
|---|---|---|---|
| PLCOPEN-CP3 | все POU `src/` (34) | «Variable … shall be initialized before being used» для входов, выходов и локальных переменных без явного начального значения | Обосновано. В CODESYS, как и по МЭК 61131-3, переменная без явного начального значения получает значение по умолчанию своего типа (0, `FALSE`; у `E_DeviceMode` это `Auto = 0`). Явные значения стоят там, где умолчание не подходит: режим `OutOfService`, уставка и гистерезис из `GVL_Const`. Вариант сборки `iec-checker` убирает неконстантные начальные значения, поэтому находка есть и для них. Часть находок — на копиях переменных в методах, которые сборка понижает до функций (`Acknowledge`, `Reset`, `Count`) |
| PLCOPEN-CP9 | `FB_Example` (тело) | «Code is too complex (28 McCabe complexity)», «(26 statements)» | Обосновано. Пороги iec_checker 0.4 — сложность > 15 и > 25 операторов, а сложность он считает завышенно: проверено на синтетическом примере, одна конструкция `IF … ELSE … END_IF` прибавляет 5. Классическая цикломатическая сложность тела — 8 (7 точек ветвления: 3 в `CASE`, 3 в `IF … ELSIF`, 1 в счётчике). Делить 40 строк линейной логики на методы ради метрики — хуже для чтения |
| PLCOPEN-L17 | `FB_Example`: `IF xFault …` в режиме `Auto`, `IF` счётчика включений | «Each IF instruction should have an ELSE clause» | Обосновано: действия «иначе» нет. В зоне гистерезиса выход сохраняет состояние, без фронта счётчик не меняется. Пустая ветка `ELSE` или присваивание переменной самой себе только добавили бы шум |
| PLCOPEN-L17 | `PRG_Main`: обработка `stCmd.xAck`, `stCmd.xReset` | то же | Обосновано: однократная команда не пришла — делать нечего |
| UnusedVariable | `PRG_Main`: `stCmd`, `stSts` | «Found unused local variable» | Ложное срабатывание: переменные используются через поля (`stCmd.xAck`, `stSts.xOut := …`), iec_checker 0.4 обращения к полям структуры не учитывает. Перепроверить на образе `nightly` |

Исправлено по итогам прогона (для истории): защёлка отказа в `FB_Example` и квитирование в
`Acknowledge` записаны логическими выражениями вместо `IF` без `ELSE`.

### Если анализируются и тесты (`assemble --tests`)

| Правило | Файл | Находка | Решение / обоснование |
|---|---|---|---|
| UnusedVariable | `FB_F_Clamp_Test`: `R_LOW`, `R_HIGH`, `R_INSIDE`, `R_BELOW`, `R_ABOVE`, `R_DELTA`; `FB_Example_Test`: `R_SP_PCT`, `R_HYST_PCT`, … `UDI_TWO_SWITCH_ONS` (10) | «Found unused local variable» | Артефакт понижения: константы набора (`VAR CONSTANT`) используются в методах-тестах, которые сборка выносит в отдельные функции |
| UnusedVariable | `FB_Example_Test`: `fbDut` в 10 методах | то же | Ложное срабатывание, как для `stCmd`/`stSts` в `PRG_Main`: экземпляр используется вызовом `fbDut(...)`, чтением выходов и вызовом методов, iec_checker 0.4 это использованием не считает (в методе, где `fbDut` присваивается интерфейсу, находки нет) |
| UnusedVariable | `PRG_Tests`: `fbF_ClampTest`, `fbExampleTest` | то же | Ложное срабатывание: экземпляры используются вызовом `AreAllTestsFinished()` и регистрируются в coUnit самим объявлением |
| PLCOPEN-CP9 | `FB_F_Clamp_Test` (1), `FB_Example_Test` (14) | «Code is too complex (16…40 McCabe complexity)», «(33…48 statements)» | Обосновано: в наборах и методах-тестах нет ветвлений (классическая сложность — 1), это последовательности вызовов и проверок; завышенный подсчёт iec_checker. Для тестов метрика не показательна |
| PLCOPEN-CP3 | `FB_F_Clamp_Test`, `FB_Example_Test`, `PRG_Tests` (25) | как выше | Обосновано, как для `src/`: результаты и экземпляры получают значения до чтения |

## RuSTy (`plc --check`)

Компилятор RuSTy 1.0.6 проверяет синтаксис и типы варианта сборки `rusty` (`src/` и `tests/`); компоновки
нет. Пространства имён `coUnit.`/`CfUnit.` убираются, объявления coUnit и блоков CODESYS Standard берутся
из прокладок `tools/check/rusty_shims/` (сигнатуры — по исследованию API, с CODESYS не сверялись).
Последний прогон — в таблице выше: 0 ошибок, 0 предупреждений, исключений нет. Найденные RuSTy ошибки
исправляются в коде; файл, который RuSTy не может разобрать из-за расширения CODESYS, заносится в
`tools/check/rusty_exclude.txt` с причиной.

## Ограничения разборщика

Конструкции CODESYS, которые iec_checker 0.4 не разбирает, — и что с ними делает вариант сборки
`iec-checker` (подробно — [LAYOUT.md](LAYOUT.md#собранный-текст-buildassembled) и `tools/README.md`):

| Конструкция | Где в примере | Как обходится |
|---|---|---|
| метки `CASE` вида `E_DeviceMode.Auto` | `FB_Example` | сборка заменяет метки целыми значениями перечисления |
| неконстантные начальные значения (`:= E_DeviceMode.OutOfService`, `:= GVL_Const.ИМЯ`) | `FB_Example`, `ST_ExampleCmd` | сборка убирает начальное значение (отсюда часть находок CP3) |
| `VAR_GLOBAL` вне `CONFIGURATION`, прагмы `{attribute …}` | `GVL_Const`, `E_DeviceMode` | сборка понижает |
| методы и свойства внутри `FUNCTION_BLOCK`, `IMPLEMENTS`, `EXTENDS` | `FB_Example`, `FB_F_Clamp_Test`, `FB_Example_Test` | сборка выносит методы в функции `<ФБ>__<метод>` — анализ методов приблизительный |

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
`F_Xorshift32`, `F_FloatContact`, `F_FaultInjEqual`. Полная проверка с библиотекой в прокладках (строка 4
таблицы) — ручной шаг: прокладки шаблона принадлежат шаблону (`tools/check/rusty_shims/*`), а библиотеку
в них копировать нельзя.
