# Отчёт о тестировании

Результаты юнит-тестов CfUnit (coUnit 1.2.0.0) в CODESYS Control Win V3 и проверок без CODESYS.
Запись «проверено в CODESYS» появляется только после реального прогона. Раздел «Последний прогон
в CODESYS» обновляет `python tools/codesys/cds.py report` по итогам `cds.py test`
(`build/test-results.json`); правки внутри него вручную перезаписываются.

<!-- cds:test-report:begin (раздел обновляет `python tools/codesys/cds.py report`) -->
## Последний прогон в CODESYS

Проверено в CODESYS 3.5.17.30 / CODESYS Control Win V3 (пользовательский процесс) — 2026-10-19 16:39:24. Итог: **все тесты пройдены**.

| Параметр | Значение |
|---|---|
| Дата прогона | 2026-10-19 16:39:24 |
| Коммит | a47fd41-dirty |
| CODESYS | 3.5.17.30 (профиль `CODESYS V3.5 SP17 Patch 3`) |
| Устройство в проекте | CODESYS Control Win V3 (4096 / 0000 0001 / 3.5.17.30) |
| Рантайм | CODESYS Control Win V3 (пользовательский процесс) |
| Фреймворк тестов | coUnit (CfUnit) 1.2.0.0 |
| Сборка | ошибок 0, предупреждений 0 |
| Способ запуска | `python tools/codesys/cds.py test` |

| Набор | Тестов | Пройдено | Упало | Пропущено | Итог |
|---|---|---|---|---|---|
| `GVL_TestsInfra.fbVfdAdapterCondTest` | 8 | 8 | 0 | 0 | пройдено |
| `GVL_TestsInfra.fbEventLogTest` | 14 | 14 | 0 | 0 | пройдено |
| `GVL_TestsInfra.fbEventLogCsvTest` | 6 | 6 | 0 | 0 | пройдено |
| `GVL_TestsInfra.fbUtcToIsoTest` | 4 | 4 | 0 | 0 | пройдено |
| `GVL_TestsInfra.fbAlarmCodeTest` | 5 | 5 | 0 | 0 | пройдено |
| `GVL_TestsInfra.fbAlarmSummaryTest` | 15 | 15 | 0 | 0 | пройдено |
| `GVL_TestsInfra.fbDeviceAuditTest` | 4 | 4 | 0 | 0 | пройдено |
| **Всего** | 56 | 56 | 0 | 0 | **пройдено** |

### Результаты тестов

| Набор | Тест | Итог |
|---|---|---|
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_DefaultsAllFalse` | пройден |
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_DecodeBits` | пройден |
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_DecodeScale5000Is100Pct` | пройден |
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_NoCommForcesStatusFalseHoldsSpeed` | пройден |
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_EncodeResetBitWhileQReset` | пройден |
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_EncodeScaleAndClamp` | пройден |
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_EncodeRoundsToNearest` | пройден |
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_EncodeNanIsZero` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_EmptyLogDefaults` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_EventRecordSizeIs40` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_AlarmEventStored` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_StationEventIdIsBasePlusCode` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_RingOverwritesOldestAndCounts` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_GetRecordNewestFirst` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_ViewPagination` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_ViewPageEqualToCountClamped` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_FeedFromSeqOldestFirst` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_FeedReportsOverwrittenGap` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_MonoTimeIsProcessTime` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_TimeBackwardsRecordedAsIs` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_SnapshotIndependentOfLaterEvents` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_SnapshotAfterWrapOldestFirst` | пройден |
| `GVL_TestsInfra.fbEventLogCsvTest` | `EventLogCsv_EventCsvLineFormat` | пройден |
| `GVL_TestsInfra.fbEventLogCsvTest` | `EventLogCsv_WritesHeaderAndAllLines` | пройден |
| `GVL_TestsInfra.fbEventLogCsvTest` | `EventLogCsv_EmptySnapshotHeaderOnly` | пройден |
| `GVL_TestsInfra.fbEventLogCsvTest` | `EventLogCsv_ReadBackMatchesSnapshot` | пройден |
| `GVL_TestsInfra.fbEventLogCsvTest` | `EventLogCsv_ErrorOnBadPathReported` | пройден |
| `GVL_TestsInfra.fbEventLogCsvTest` | `EventLogCsv_SlowTaskRequestHandshake` | пройден |
| `GVL_TestsInfra.fbUtcToIsoTest` | `UtcToIso_ZeroIsEmpty` | пройден |
| `GVL_TestsInfra.fbUtcToIsoTest` | `UtcToIso_KnownDates` | пройден |
| `GVL_TestsInfra.fbUtcToIsoTest` | `UtcToIso_CenturyLeapDay2000` | пройден |
| `GVL_TestsInfra.fbUtcToIsoTest` | `UtcToIso_ZeroPadDigits` | пройден |
| `GVL_TestsInfra.fbAlarmCodeTest` | `AlarmCode_DeviceSuffixesByType` | пройден |
| `GVL_TestsInfra.fbAlarmCodeTest` | `AlarmCode_StationAlarms` | пройден |
| `GVL_TestsInfra.fbAlarmCodeTest` | `AlarmCode_Lic101AndEvents` | пройден |
| `GVL_TestsInfra.fbAlarmCodeTest` | `AlarmCode_UnknownIsNumber` | пройден |
| `GVL_TestsInfra.fbAlarmCodeTest` | `AlarmCode_SlotWithoutSuffixIsNumber` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_EmptyDefaults` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_SlotMaxMatchesLibrary` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_CountsByPriority` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_PrioUnackHighest` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_PrioUnackHighestBeforeLower` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_NewHighSeqOnlyOnTransition` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_ViewSortedUnackFirst` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_ViewNewerFirstInGroup` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_ViewLimitedToRows` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_ViewPeriodRespected` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_TimeBackwardsRebuildsView` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_AckByIdDeviceStationPid` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_ShelveByIdRespectsTShelveMax` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_ShelveByIdUsesFullTShelveMax` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_UnshelveById` | пройден |
| `GVL_TestsInfra.fbDeviceAuditTest` | `DeviceAudit_NoEventOnFirstCall` | пройден |
| `GVL_TestsInfra.fbDeviceAuditTest` | `DeviceAudit_AuditLogsModeChange` | пройден |
| `GVL_TestsInfra.fbDeviceAuditTest` | `DeviceAudit_NoSinkIsSafe` | пройден |
| `GVL_TestsInfra.fbDeviceAuditTest` | `DeviceAudit_LargeDevNoValueNoOverflow` | пройден |

### Упавшие тесты

_Нет._

Машиночитаемые результаты: `build/test-results.json`, `build/junit.xml` (не в git).
<!-- cds:test-report:end -->

## Сборка и полная проверка компиляции в CODESYS

CODESYS 3.5.17.30, профиль `CODESYS V3.5 SP17 Patch 3`, локально, 19.10.2026 — ветка команды К3
(сгенерированный слой, полевой слой, журнал). Объекты логики станции и модели (К1, К2), на которые
ссылаются задачи и сгенерированный слой (`PRG_Station`, `PRG_PlantModel`, `GVL_Time`, `GVL_Sim`, типы станции
и имитации), подставлены копиями из веток команд (в коммиты К3 не входят): итог для объединённого проекта —
после слияния.

| Команда | Итог | Примечание |
|---|---|---|
| `cds.py deps --check` | все есть | plc-process-lib 1.0.0.0, CAA File 3.5.17.0, SysTimeRtc 3.5.17.0, coUnit 1.2.0.0, Standard |
| `cds.py check` | 0 ошибок, 0 предупреждений | 58 объектов `src/` (с копиями объектов К1, К2) |
| `cds.py check --tests` | 0 ошибок, 0 предупреждений | 68 объектов `src/` и `tests/` |
| `cds.py build` | 0 ошибок, 0 предупреждений | MainTask, PlantModelTask, SlowTask; Persistent Variables — `codesys_pvl.py` (MANUAL_STEPS 9.3) |
| `cds.py build --tests` | 0 ошибок, 0 предупреждений | — |
| `cds.py test` | 56 из 56 | раздел выше; мутационное тестирование — раздел ниже |
| `symbol_config.py` (сборки `sim` и `site`) | файл символов совпал с правилами | `sim`: `GVL_Devices` 29 Read, `GVL_Hmi` 30 ReadWrite, `GVL_IO` 86 Read, `GVL_Log` 4 Read + 2 ReadWrite, `GVL_Persist` 37 ReadWrite, `GVL_Sim` 3 + 3, `GVL_Time` 1; поля типов: `ST_EventView` — запись только `uiPage`, `ST_EventFeed` — только `udiFromSeq`, `ST_EventRecord` — только чтение; `site`: `GVL_Persist` 37 Read, `GVL_Sim` 3 Read; повтор — 0 изменений |
| `cds.py roundtrip` | не запускался | в чистом проекте нет объекта Persistent Variables (создаёт только `codesys_pvl.py`), экспорт без `GVL_Persist` дал бы дифф |

## Мутационное тестирование (19.10.2026)

Копия рабочей копии с объектами К1 и К2 (вне репозитория), по одному изменению поведения на мутант (у ST —
группами по непересекающимся наборам тестов), `cds.py test` в CODESYS Control Win и `pytest` для Python.
Мутант убит, если упал хотя бы один тест его набора. Выжившие после первого прохода закрыты новыми тестами
(указаны в скобках) и прогнаны повторно.

| Поведение | Мутантов | Убито | Примеры мутантов и тесты, которые их ловят |
|---|---:|---:|---|
| Адаптер ПЧ, `Decode`: связь, биты, масштаб | 6 | 6 | `xCommOk := TRUE`, авария без связи, скорость без связи, бит «готов» от «в работе», масштаб 1/100 — `NoCommForcesStatusFalseHoldsSpeed`, `DecodeBits`, `DecodeScale5000Is100Pct` |
| Адаптер ПЧ, `Encode`: бит сброса, масштаб, предел, округление, NaN | 6 | 6 | инверсия и не тот бит сброса, отбрасывание дробной части (`EncodeRoundsToNearest`), без предела 100 %, NaN держит задание — `EncodeResetBitWhileQReset`, `EncodeScaleAndClamp`, `EncodeNanIsZero` |
| Журнал: кольцо, затирание, номера, время | 5 | 5 | затирание не считается, кольцо короче на запись, время мимо `itfTime`, пропуск номеров, `GetRecord` со сдвигом — `RingOverwritesOldestAndCounts`, `MonoTimeIsProcessTime` и др. |
| Журнал: курсор и страницы | 5 | 5 | курсор без ограничения самой старой записью, первая запись со сдвигом, неочищенные строки, счётчик строк, ограничение номера страницы (`ViewPageEqualToCountClamped`) |
| Журнал: снимок | 3 | 3 | порядок кольца без перестановки (`SnapshotAfterWrapOldestFirst`), «новые первыми», граница индекса |
| Выгрузка CSV и обмен `PRG_Slow` | 7 | 6 | прежний обмен, снятие запроса только по `Done`, вторая выгрузка не стартует, без заголовка, без счёта строк, потеря кода ошибки открытия — `SlowTaskRequestHandshake`, `ReadBackMatchesSnapshot`, `WritesHeaderAndAllLines`, `ErrorOnBadPathReported`. Выжил: «успех после ошибки записи» — ветка ошибки `FILE.Write`/`FILE.Close`, её на Control Win не вызвать без внедрения отказа в CAA File (закрыта ревью кода) |
| `F_UtcToIso` | 5 | 5 | февраль без переноса года, сдвиг эпохи, миллисекунды без двух нулей, правило 400 лет (`CenturyLeapDay2000`), 0 → не пусто |
| `F_AlarmCode` | 4 | 4 | таблица задвижки для двигателя, номер события со сдвигом, первая тревога станции, слот без суффикса (`SlotWithoutSuffixIsNumber`) |
| `FB_AlarmSummary` | 7 | 7 | RtnUnack как активная, приоритет последней вместо высшей (`PrioUnackHighestBeforeLower`), новые High каждый цикл, квитированные в группе неквитированных, без «новые выше» (`ViewNewerFirstInGroup`), пересчёт каждый цикл, свой срок откладывания (`ShelveByIdUsesFullTShelveMax`) |
| Обвязка сценариев (Python) | 12 | 11 | граница поиска по номеру журнала, допуск `max_s`/`min_s`, единицы TIME/LTIME, перезапуск журнала, пропуск одной записи, ошибки шага в отчёте, переполнение списка тревог, импульс без ожидания сброса — `scenarios/test_harness_robustness.py`, `test_harness.py`. Выжил: курсор принимает строки «номер ≥ ожидаемого» вместо «=» — эквивалентен: `FillFeed` отдаёт строки подряд с `MAX(udiFromSeq, первая)`, а пропуск ловится раньше |
| Символьная конфигурация (Python) | 6 | 6 | последнее правило вместо первого, регистр имён, поля всегда ReadWrite, без сверки полей, доступ без учёта сборки, переменная без правила не замечена — `test_symbol_config.py`, `test_scenario_files.py` |
| **Всего** | **66** | **64** | |

## Что проверяют тесты

| Набор | Тестов | Что проверяет |
|---|---:|---|
| `FB_VfdAdapter_Cond_Test` | 8 | биты слова состояния, масштаб 5000 = 100 %, без связи статусы FALSE и последняя скорость, бит сброса, задание с ограничением и округлением до ближайшего отсчёта, NaN и +Inf → 0, умолчания |
| `FB_EventLog_Test` | 14 | запись тревоги и события станции (101000 + код), кольцо на 200 и счётчик затёртых, «новые первыми», страницы HMI (в том числе номер, равный числу страниц), курсор и пропуск затёртых, время процесса, «время назад», снимок (в том числе после затирания кольца), размер записи 40 байт, пустой журнал |
| `FB_EventLogCsv_Test` | 6 | формат строки CSV; в рантайме через CAA File: заголовок и 25 строк, пустой снимок, чтение файла назад побайтно, ошибка открытия, обмен `PRG_Slow` ↔ MainTask (запрос снят при старте, вторая выгрузка сразу после `Done`) |
| `FB_F_UtcToIso_Test` | 4 | ISO 8601 по эталонам Python (29.02.2024, 2100 год, 29.02.2000 — граница 400-летнего цикла), 0 → пусто, ведущие нули |
| `FB_F_AlarmCode_Test` | 5 | коды устройств по типу и слоту (слот без суффикса — номер слота), тревоги станции, LIC101.PVF, KNS1.E<код>, неизвестные номера |
| `FB_AlarmSummary_Test` | 15 | счётчики по приоритетам, высший неквитированный (независимо от порядка обхода), новые High/Critical, порядок списка (группа, приоритет, новые выше) и его предел, период и «время назад», квитирование и откладывание по номеру с `tShelveMax` (весь срок тревоги), соответствие `ALM_SLOT_MAX` библиотеке |
| `FB_DeviceAudit_Test` | 4 | событие 101018 со значением dev_no · 10 + режим (dev_no 9999 — без переполнения), без события при старте и без журнала |

## Проверки без CODESYS

| Проверка | Итог | Примечание |
|---|---|---|
| `ruff check`, `ruff format --check`, `mypy` (strict) | пройдено, 19.10.2026, локально | `tools/`, `tools_project/`, `scenarios/` |
| `pytest` | 675 пройдено, 4 пропущено (19.10.2026) | сверка генерации побайтно (`test_generate.py`), таблица перечислений, правила символов (переменные и поля типов), обвязка сценариев на имитаторе OPC UA-сервера (PMI-13 целиком) и на подменном клиенте (единицы TIME, задержки от метки, перезапуск журнала, пропуск записей, переполнение списка тревог), таблицы суффиксов `F_AlarmCode` против `docs/alarms.csv` и 05, офлайн-проверка файлов сценариев; пропущены — сценарии на рантайме (`PMI_LIVE=1`) и каталог 39 сценариев (ещё нет) |
| `tools_project/generate.py --check` | дрейфа нет (20 файлов) | iolistgen 0.2.0 |
| `tools_project/check_docs_consistency.py` | 20 проверок, 0 расхождений | сверки с генератором и исходниками библиотеки — по `IOLISTGEN_REPO`/`PL_REPO` или соседним репозиториям (из рабочей копии `_wt/` — на уровень выше) |
| `st_lint --strict`, iec_checker 0.4, RuSTy 1.0.6 | 0 ошибок, необоснованных находок 0 | [STATIC_ANALYSIS.md](STATIC_ANALYSIS.md), раздел К3 |
