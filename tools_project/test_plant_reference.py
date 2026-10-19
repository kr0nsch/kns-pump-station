"""Тесты эталона модели (plant_reference.py): числа документов и независимые решения.

1. Подбор характеристики насоса и сети (DESIGN 11.3, ASSUMPTIONS T9): подачи, токи, давления.
2. Рабочая точка бисекцией совпадает с решением в замкнутой форме (одинаковые скорости).
3. Ливни: xorshift32 по известным значениям, детерминизм, границы выборок, трапеция.
4. Профиль притока: среднее 1,0, пик и минимум (06 §5.4), интерполяция, полночь.
5. Резервуар: баланс объёма, перелив, сухой приёмок.
6. Оценки времени в документах (PMI-20/24, DESIGN 14.4).
"""

from __future__ import annotations

import math

import pytest

import plant_reference as P

PUMP = P.PumpCfg()


def _closed_form_flow(n: int, speed: float, level_m: float) -> float:
    """n одинаковых насосов: H0·s² − k·q² = (Hgeo − h) + R·(n·q)² → q = √((H0·s² − Hst)/(k + R·n²))."""
    h_static = PUMP.hgeo_m - level_m
    return n * math.sqrt((PUMP.h0_m * speed**2 - h_static) / (PUMP.k_mh2 + PUMP.r_mh2 * n * n))


@pytest.mark.parametrize(
    ("speeds", "level", "expected", "tol"),
    [
        ([1.0, 0.0, 0.0], 1.4, 150.0, 0.5),  # один насос 100 % — 150 м³/ч
        ([0.6, 0.0, 0.0], 1.4, 41.0, 0.5),  # 60 % — 41 м³/ч
        ([0.75, 0.75, 0.0], 1.4, 120.0, 0.5),  # два по 75 % — 120 м³/ч
        ([0.87, 0.0, 0.0], 1.4, 120.0, 1.0),  # один 87 % — 120 м³/ч
        ([1.0, 1.0, 0.0], 1.4, 198.0, 0.5),  # два на 50 Гц — ≈ 198
        ([1.0, 1.0, 1.0], 1.4, 213.0, 0.5),  # три — ≈ 213
        ([1.0, 1.0, 1.0], 4.0, 224.0, 0.5),  # три на 4,0 м — ≈ 224
    ],
)
def test_station_flows_match_documents(speeds: list[float], level: float, expected: float, tol: float) -> None:
    assert P.hydraulic_point(speeds, level, PUMP).flow_m3h == pytest.approx(expected, abs=tol)


@pytest.mark.parametrize(("n", "speed", "level"), [(1, 1.0, 1.4), (1, 0.6, 1.4), (2, 0.75, 1.4), (3, 1.0, 4.0)])
def test_bisection_matches_closed_form(n: int, speed: float, level: float) -> None:
    speeds = [speed] * n + [0.0] * (3 - n)
    exact = _closed_form_flow(n, speed, level)
    assert P.hydraulic_point(speeds, level, PUMP).flow_m3h == pytest.approx(exact, rel=1e-9)
    # 30 итераций, как в ПЛК: погрешность много меньше допусков тестов ST (0,05 м³/ч)
    plc = P.hydraulic_point(speeds, level, PUMP, iterations=P.SOLVER_ITERATIONS).flow_m3h
    assert plc == pytest.approx(exact, abs=1e-3)


def test_motor_currents_match_documents() -> None:
    # DESIGN 11.3: один насос 100 % ≈ 26,4 А; сухой ход ≈ 10,8 А < 12 А; засор ≈ 34,3 А > 34 А
    assert P.hydraulic_point([1.0, 0.0, 0.0], 1.4).currents_a[0] == pytest.approx(26.4, abs=0.05)
    air = P.hydraulic_point([1.0, 0.0, 0.0], 1.4, air_lock=[True, False, False])
    assert air.currents_a[0] == pytest.approx(10.75, abs=0.01)
    assert air.currents_a[0] < 12.0  # порог недогрузки 04 §10.3
    assert air.flows_m3h[0] == 0.0
    clog = P.hydraulic_point([1.0, 0.0, 0.0], 1.4, clog=[True, False, False])
    assert clog.currents_a[0] == pytest.approx(34.3, abs=0.05)
    assert clog.currents_a[0] > 34.0  # уставка HH IT1n1
    assert clog.flows_m3h[0] == pytest.approx(75.0, abs=0.1)  # подача упала


def test_clog_reduces_flow_by_sixty_percent_at_same_head() -> None:
    # засор: крутизна ×6,25 → при том же напоре подача ×0,4
    head = 15.0
    q_ok = math.sqrt((PUMP.h0_m - head) / PUMP.k_mh2)
    q_clog = math.sqrt((PUMP.h0_m - head) / (PUMP.k_mh2 * P.CLOG_K_FACTOR))
    assert q_clog / q_ok == pytest.approx(0.4)


def test_pressures_match_hmi_ranges() -> None:
    # ASSUMPTIONS T8: один насос на минимуме ≈ 1,25 бар; закрытая задвижка ≈ 3,5 бар; насосы стоят — столб Hgeo
    assert P.hydraulic_point([0.6, 0.0, 0.0], 1.4).pressure_bar == pytest.approx(1.25, abs=0.01)
    closed = P.scenarios()["hydraulic.closed_valve_100"]["pressure_bar"]
    assert closed == pytest.approx(3.5, abs=0.05)
    stopped = P.hydraulic_point([0.0, 0.0, 0.0], 2.0).pressure_bar
    assert stopped == pytest.approx(P.RHO_KGM3 * P.G_MPS2 * PUMP.hgeo_m / P.PA_PER_BAR)


def test_check_valve_closes_for_slower_pump() -> None:
    p = P.hydraulic_point([1.0, 0.6, 0.0], 1.4)
    assert p.flows_m3h[1] == 0.0
    assert p.flows_m3h[0] == pytest.approx(P.hydraulic_point([1.0, 0.0, 0.0], 1.4).flows_m3h[0])
    both = P.hydraulic_point([1.0, 0.9, 0.0], 1.4)
    assert 0.0 < both.flows_m3h[1] < both.flows_m3h[0]


def test_no_flow_below_static_head_and_dry_intake() -> None:
    weak = P.hydraulic_point([0.55, 0.0, 0.0], 1.4)  # 34,5·0,55² = 10,44 м < 10,6 м
    assert weak.flow_m3h == 0.0
    assert weak.head_m == pytest.approx(PUMP.hgeo_m - 1.4)
    dry = P.hydraulic_point([1.0, 0.0, 0.0], P.PUMP_INTAKE_M - 0.05)
    assert dry.flow_m3h == 0.0
    assert dry.currents_a[0] < 12.0  # насос «подсасывает воздух» — недогрузка


def test_pump_current_continuous_at_zero_flow() -> None:
    # потребляемая мощность не меньше потерь холостого хода: нет скачка тока при закрытии обратного клапана
    near = P.pump_current(0.01, PUMP.h0_m * 0.36, 0.6, PUMP)
    zero = P.pump_current(0.0, PUMP.h0_m * 0.36, 0.6, PUMP)
    assert near == pytest.approx(zero, abs=1e-3)
    assert P.pump_current(100.0, 20.0, 0.0, PUMP) == 0.0


def test_equilibrium_level_balances_inflow() -> None:
    h = P.equilibrium_level([0.87, 0.0, 0.0], 120.0)
    assert P.hydraulic_point([0.87, 0.0, 0.0], h).flow_m3h == pytest.approx(120.0, abs=1e-6)
    assert 1.0 < h < 1.4


def test_xorshift_known_values() -> None:
    # Marsaglia, 2003: xorshift32 (13, 17, 5) из 1 — 270369
    assert P.xorshift32(1) == 270369
    assert P.xorshift32(0) == 0  # поэтому нулевое состояние заменяется SIM_XS_ZERO_STATE
    x = 20261016
    for _ in range(1000):
        x = P.xorshift32(x)
        assert 0 < x <= P.MASK32


def test_storms_are_deterministic_and_within_bounds() -> None:
    cfg = P.SimCfg()
    for day in range(30):
        first = P.storms_for_day(day, cfg)
        assert first == P.storms_for_day(day, cfg)
        assert len(first) <= cfg.storms_per_day_max
        for s in first:
            assert 0.0 <= s.start_h < P.HOURS_PER_DAY
            assert cfg.storm_min_ms <= s.duration_ms <= cfg.storm_max_ms
            assert cfg.storm_peak_min_m3h <= s.peak_m3h < cfg.storm_peak_max_m3h
    assert P.storms_for_day(0, cfg) != P.storms_for_day(1, cfg)
    other = P.SimCfg(seed=cfg.seed + 1)
    assert any(P.storms_for_day(d, cfg) != P.storms_for_day(d, other) for d in range(5))


def test_storm_count_uses_full_range() -> None:
    cfg = P.SimCfg()
    counts = {len(P.storms_for_day(d, cfg)) for d in range(200)}
    assert counts == {0, 1, 2}


def test_zero_seed_day_zero_does_not_stall() -> None:
    cfg = P.SimCfg(seed=0, storms_per_day_max=4)
    assert P.storms_for_day(0, cfg) == P.storms_for_day(0, cfg)
    assert any(P.storms_for_day(d, cfg) for d in range(10))


def test_storm_trapezoid() -> None:
    d, peak = 3600.0, 200.0
    assert P.storm_shape(0.0, d, peak) == 0.0
    assert P.storm_shape(0.075 * d, d, peak) == pytest.approx(peak / 2)
    assert P.storm_shape(0.15 * d, d, peak) == pytest.approx(peak)
    assert P.storm_shape(0.65 * d - 1e-6, d, peak) == pytest.approx(peak)
    assert P.storm_shape(0.825 * d, d, peak) == pytest.approx(peak / 2)
    assert P.storm_shape(d, d, peak) == 0.0
    assert P.storm_shape(-1.0, d, peak) == 0.0
    # объём трапеции = пик · (0,5·0,15 + 0,5 + 0,5·0,35) · D = 0,75 · пик · D
    n = 36000
    vol = sum(P.storm_shape((i + 0.5) * d / n, d, peak) for i in range(n)) * d / n
    assert vol == pytest.approx(0.75 * peak * d, rel=1e-6)


def test_storm_crossing_midnight_continues_next_day() -> None:
    cfg = P.SimCfg()
    # ищем ливень, который не закончился к полуночи, и проверяем приток после полуночи
    for day in range(60):
        for s in P.storms_for_day(day, cfg):
            end_h = s.start_h + s.duration_ms / 1000.0 / P.S_PER_H
            if end_h > P.HOURS_PER_DAY + 0.01:
                after = (day + 1) * P.HOURS_PER_DAY + 0.005
                assert P.storm_inflow(after, cfg) > 0.0
                return
    pytest.skip("в первых 60 сутках нет ливня через полночь")


def test_inflow_profile() -> None:
    assert sum(P.DAILY_PROFILE) / len(P.DAILY_PROFILE) == pytest.approx(1.0)
    assert P.inflow_factor(8.0) == pytest.approx(1.60)
    assert P.inflow_factor(8.5) == pytest.approx(1.55)
    assert P.inflow_factor(23.5) == pytest.approx(0.625)  # между 0,70 (23 ч) и 0,55 (0 ч)
    assert P.inflow_factor(24.25) == pytest.approx(P.inflow_factor(0.25))
    assert P.inflow_factor(-0.5) == pytest.approx(P.inflow_factor(23.5))
    vals = P.scenarios()["inflow.profile"]
    assert vals["peak_m3h"] == pytest.approx(112.0)  # 06 §5.4: 27…112 м³/ч
    assert round(vals["min_m3h"]) == 27
    assert vals["mean_factor"] == pytest.approx(1.0)


def test_tank_balance_overflow_and_dry_intake() -> None:
    tank = P.Tank(level_m=1.2)
    for _ in range(360):
        tank.step(30.0, 10.0, 10.0)
    assert tank.level_m == pytest.approx(1.2 + 20.0 / 12.0)
    tank = P.Tank(level_m=4.5)
    for _ in range(60):
        tank.step(250.0, 0.0, 10.0)
    assert tank.level_m == pytest.approx(4.6)
    assert tank.overflow_s > 0.0
    dry = P.Tank(level_m=0.25)
    dry.step(0.0, 150.0, 60.0)
    assert dry.level_m == pytest.approx(0.25)


def test_pmi20_timeline_matches_design() -> None:
    # DESIGN 14.4: от И0 при 250 м³/ч HH через ≈ 33 мин, 4,20 м — ≈ 38, 4,40 м — ≈ 44, перелив — ≈ 50
    vals = P.scenarios()["pmi20.inflow_250"]
    assert vals["t_4.0m_min"] == pytest.approx(33.0, abs=1.0)
    assert vals["t_4.2m_min"] == pytest.approx(38.0, abs=1.0)
    assert vals["t_4.4m_min"] == pytest.approx(44.0, abs=1.0)
    assert vals["t_4.6m_min"] == pytest.approx(50.0, abs=1.0)


def test_default_seed_day_reported() -> None:
    # PMI-39: эталон сообщает, есть ли перелив в сутки 0 для seed по умолчанию (упрощённая станция)
    vals = P.scenarios()["pmi39.day0_stepped"]
    assert vals["overflow_s"] == 0.0
    assert vals["max_level_m"] < 4.0


def test_main_prints_values(capsys: pytest.CaptureFixture[str]) -> None:
    assert P.main([]) == 0
    out = capsys.readouterr().out
    assert "hydraulic.one_pump_100.flow_m3h = 149.7" in out
    assert P.main(["--json"]) == 0
    assert '"storms.day0"' in capsys.readouterr().out
