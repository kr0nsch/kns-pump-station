# Отчёт о тестировании

Результаты юнит-тестов CfUnit (coUnit 1.2.0.0) в CODESYS Control Win V3 и проверок без CODESYS.
Запись «проверено в CODESYS» появляется только после реального прогона. Раздел «Последний прогон
в CODESYS» обновляет `python tools/codesys/cds.py report` по итогам `cds.py test`
(`build/test-results.json`); правки внутри него вручную перезаписываются.

<!-- cds:test-report:begin (раздел обновляет `python tools/codesys/cds.py report`) -->
## Последний прогон в CODESYS

Проверено в CODESYS 3.5.17.30 / CODESYS Control Win V3 (пользовательский процесс) — 2026-10-19 14:48:27. Итог: **все тесты пройдены**.

| Параметр | Значение |
|---|---|
| Дата прогона | 2026-10-19 14:48:27 |
| Коммит | 6862703-dirty |
| CODESYS | 3.5.17.30 (профиль `CODESYS V3.5 SP17 Patch 3`) |
| Устройство в проекте | CODESYS Control Win V3 (4096 / 0000 0001 / 3.5.17.30) |
| Рантайм | CODESYS Control Win V3 (пользовательский процесс) |
| Фреймворк тестов | coUnit (CfUnit) 1.2.0.0 |
| Сборка | ошибок 0, предупреждений 0 |
| Способ запуска | `python tools/codesys/cds.py test` |

| Набор | Тестов | Пройдено | Упало | Пропущено | Итог |
|---|---|---|---|---|---|
| `GVL_TestsInfra.fbVfdAdapterCondTest` | 7 | 7 | 0 | 0 | пройдено |
| `GVL_TestsInfra.fbEventLogTest` | 12 | 12 | 0 | 0 | пройдено |
| `GVL_TestsInfra.fbEventLogCsvTest` | 5 | 5 | 0 | 0 | пройдено |
| `GVL_TestsInfra.fbUtcToIsoTest` | 3 | 3 | 0 | 0 | пройдено |
| `GVL_TestsInfra.fbAlarmCodeTest` | 4 | 4 | 0 | 0 | пройдено |
| `GVL_TestsInfra.fbAlarmSummaryTest` | 12 | 12 | 0 | 0 | пройдено |
| `GVL_TestsInfra.fbDeviceAuditTest` | 3 | 3 | 0 | 0 | пройдено |
| **Всего** | 46 | 46 | 0 | 0 | **пройдено** |

### Результаты тестов

| Набор | Тест | Итог |
|---|---|---|
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_DefaultsAllFalse` | пройден |
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_DecodeBits` | пройден |
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_DecodeScale5000Is100Pct` | пройден |
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_NoCommForcesStatusFalseHoldsSpeed` | пройден |
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_EncodeResetBitWhileQReset` | пройден |
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_EncodeScaleAndClamp` | пройден |
| `GVL_TestsInfra.fbVfdAdapterCondTest` | `VfdAdapter_EncodeNanIsZero` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_EmptyLogDefaults` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_EventRecordSizeIs40` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_AlarmEventStored` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_StationEventIdIsBasePlusCode` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_RingOverwritesOldestAndCounts` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_GetRecordNewestFirst` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_ViewPagination` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_FeedFromSeqOldestFirst` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_FeedReportsOverwrittenGap` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_MonoTimeIsProcessTime` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_TimeBackwardsRecordedAsIs` | пройден |
| `GVL_TestsInfra.fbEventLogTest` | `EventLog_SnapshotIndependentOfLaterEvents` | пройден |
| `GVL_TestsInfra.fbEventLogCsvTest` | `EventLogCsv_EventCsvLineFormat` | пройден |
| `GVL_TestsInfra.fbEventLogCsvTest` | `EventLogCsv_WritesHeaderAndAllLines` | пройден |
| `GVL_TestsInfra.fbEventLogCsvTest` | `EventLogCsv_EmptySnapshotHeaderOnly` | пройден |
| `GVL_TestsInfra.fbEventLogCsvTest` | `EventLogCsv_ReadBackMatchesSnapshot` | пройден |
| `GVL_TestsInfra.fbEventLogCsvTest` | `EventLogCsv_ErrorOnBadPathReported` | пройден |
| `GVL_TestsInfra.fbUtcToIsoTest` | `UtcToIso_ZeroIsEmpty` | пройден |
| `GVL_TestsInfra.fbUtcToIsoTest` | `UtcToIso_KnownDates` | пройден |
| `GVL_TestsInfra.fbUtcToIsoTest` | `UtcToIso_ZeroPadDigits` | пройден |
| `GVL_TestsInfra.fbAlarmCodeTest` | `AlarmCode_DeviceSuffixesByType` | пройден |
| `GVL_TestsInfra.fbAlarmCodeTest` | `AlarmCode_StationAlarms` | пройден |
| `GVL_TestsInfra.fbAlarmCodeTest` | `AlarmCode_Lic101AndEvents` | пройден |
| `GVL_TestsInfra.fbAlarmCodeTest` | `AlarmCode_UnknownIsNumber` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_EmptyDefaults` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_SlotMaxMatchesLibrary` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_CountsByPriority` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_PrioUnackHighest` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_NewHighSeqOnlyOnTransition` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_ViewSortedUnackFirst` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_ViewLimitedToRows` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_ViewPeriodRespected` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_TimeBackwardsRebuildsView` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_AckByIdDeviceStationPid` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_ShelveByIdRespectsTShelveMax` | пройден |
| `GVL_TestsInfra.fbAlarmSummaryTest` | `AlarmSummary_UnshelveById` | пройден |
| `GVL_TestsInfra.fbDeviceAuditTest` | `DeviceAudit_NoEventOnFirstCall` | пройден |
| `GVL_TestsInfra.fbDeviceAuditTest` | `DeviceAudit_AuditLogsModeChange` | пройден |
| `GVL_TestsInfra.fbDeviceAuditTest` | `DeviceAudit_NoSinkIsSafe` | пройден |

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
| `cds.py check` | 0 ошибок, 0 предупреждений | 51 объект `src/` |
| `cds.py check --tests` | 0 ошибок, 0 предупреждений | 61 объект `src/` и `tests/` |
| `cds.py build` | 0 ошибок, 0 предупреждений | MainTask, PlantModelTask, SlowTask; Persistent Variables — `codesys_pvl.py` (MANUAL_STEPS 9.3) |
| `cds.py build --tests` | 0 ошибок, 0 предупреждений | — |
| `cds.py test` | 46 из 46 | раздел выше; отрицательный контроль: порча индекса кольца журнала и удержание аварии ПЧ без связи в адаптере — 12 тестов упали, после возврата — зелёные |
| `symbol_config.py` (сборка `sim`) | файл символов совпал с правилами | `GVL_Devices` 29 Read, `GVL_Hmi` 30 ReadWrite, `GVL_IO` 86 Read, `GVL_Log` 4 Read + 2 ReadWrite, `GVL_Persist` 37 ReadWrite, `GVL_Sim` 3 + 3, `GVL_Time` 1; повтор — 0 изменений |
| `cds.py roundtrip` | не запускался | в чистом проекте нет объекта Persistent Variables (создаёт только `codesys_pvl.py`), экспорт без `GVL_Persist` дал бы дифф |

## Что проверяют тесты

| Набор | Тестов | Что проверяет |
|---|---:|---|
| `FB_VfdAdapter_Cond_Test` | 7 | биты слова состояния, масштаб 5000 = 100 %, без связи статусы FALSE и последняя скорость, бит сброса, задание с ограничением и округлением, NaN и +Inf → 0, умолчания |
| `FB_EventLog_Test` | 12 | запись тревоги и события станции (101000 + код), кольцо на 200 и счётчик затёртых, «новые первыми», страницы HMI, курсор и пропуск затёртых, время процесса, «время назад», снимок, размер записи 40 байт, пустой журнал |
| `FB_EventLogCsv_Test` | 5 | формат строки CSV; в рантайме через CAA File: заголовок и 25 строк, пустой снимок, чтение файла назад побайтно, ошибка открытия |
| `FB_F_UtcToIso_Test` | 3 | ISO 8601 по эталонам Python (29.02.2024, 2100 год), 0 → пусто, ведущие нули |
| `FB_F_AlarmCode_Test` | 4 | коды устройств по типу и слоту, тревоги станции, LIC101.PVF, KNS1.E<код>, неизвестные номера |
| `FB_AlarmSummary_Test` | 12 | счётчики по приоритетам, высший неквитированный, новые High/Critical, порядок и предел списка, период и «время назад», квитирование и откладывание по номеру с `tShelveMax`, соответствие `ALM_SLOT_MAX` библиотеке |
| `FB_DeviceAudit_Test` | 3 | событие 101018 со значением dev_no · 10 + режим, без события при старте и без журнала |

## Проверки без CODESYS

| Проверка | Итог | Примечание |
|---|---|---|
| `ruff check`, `ruff format --check`, `mypy` (strict) | пройдено, 19.10.2026, локально | `tools/`, `tools_project/`, `scenarios/` |
| `pytest` | 647 пройдено, 8 пропущено (19.10.2026) | сверка генерации побайтно (`test_generate.py`), таблица перечислений, правила символов, обвязка сценариев на имитаторе OPC UA-сервера (PMI-13 целиком), офлайн-проверка файлов сценариев; пропущены — сценарии на рантайме (`PMI_LIVE=1`) и каталог 39 сценариев (ещё нет) |
| `tools_project/generate.py --check` | дрейфа нет (20 файлов) | iolistgen 0.2.0 |
| `tools_project/check_docs_consistency.py` | 20 проверок, 0 расхождений | с `IOLISTGEN_REPO` и `PL_REPO` — и сверки с генератором и исходниками библиотеки |
| `st_lint --strict`, iec_checker 0.4, RuSTy 1.0.6 | 0 ошибок, необоснованных находок 0 | [STATIC_ANALYSIS.md](STATIC_ANALYSIS.md), раздел К3 |
