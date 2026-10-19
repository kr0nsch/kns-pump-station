"""Эталон модели объекта КНС-1 (docs/DESIGN.md, раздел 11): те же уравнения, что в ST, в float64.

Модель в ПЛК считает в REAL (32 бит), эталон — в двойной точности, поэтому тесты ST сравнивают с
допуском (строка ``// ref: <сценарий>.<ключ>`` перед ассертом). Числа документов (DESIGN 11.3,
ASSUMPTIONS T9, 06 §14.4 DESIGN) проверяет ``test_plant_reference.py``.

Состав:

* законы подобия и рабочая точка N насосов на общую сеть (бисекция по напору, как в
  ``FB_HydraulicSolver``), ток двигателя (``F_PumpCurrent``), давление PT201;
* суточный профиль притока (``FB_InflowProfile``), ливни по seed (``F_Xorshift32``,
  ``FB_StormGenerator``), трапеция ливня;
* баланс объёма резервуара (``FB_TankModel``);
* упрощённая станция «ступенчатое + аварийный режим» (04 §6, §10.2) — только для оценок времени
  в документах (PMI-20, PMI-39); настоящую логику проверяют интеграционные тесты ST.

Запуск: ``python tools_project/plant_reference.py`` печатает все эталонные значения
``сценарий.ключ = значение``; ``--json`` — то же в JSON.
"""

from __future__ import annotations

import argparse
import functools
import json
import math
from collections.abc import Callable, Sequence
from dataclasses import dataclass, field, replace

# --- физика и константы GVL_Const (раздел «Модель») -------------------------------------------------
G_MPS2 = 9.81
RHO_KGM3 = 1000.0
S_PER_H = 3600.0
PA_PER_BAR = 1.0e5
W_PER_KW = 1000.0
FREQ_NOM_HZ = 50.0
HOURS_PER_DAY = 24.0
SOLVER_ITERATIONS = 30
CLOG_K_FACTOR = 6.25
CLOG_I_FACTOR = 1.3
PUMP_INTAKE_M = 0.30
STORM_RISE_SHARE = 0.15
STORM_FALL_SHARE = 0.35
SEED_DAY_MUL = 0x9E3779B9
XS_ZERO_STATE = 0x2545F491
U24_MASK = 0x00FFFFFF
U24_SCALE = 16777216.0
MASK32 = 0xFFFFFFFF
LS102_MARK_M = 4.20
LS103_MARK_M = 0.40

DAILY_PROFILE: tuple[float, ...] = (
    0.55, 0.45, 0.40, 0.38, 0.40, 0.55, 0.92, 1.35, 1.60, 1.50, 1.30, 1.15,
    1.10, 1.05, 1.00, 1.00, 1.00, 1.15, 1.35, 1.50, 1.45, 1.20, 0.95, 0.70,
)  # fmt: skip


@dataclass(frozen=True)
class PumpCfg:
    """ST_PumpModelCfg: характеристика насоса и сети (значения по умолчанию — DESIGN 11.3)."""

    h0_m: float = 34.5
    k_mh2: float = 6.06e-4
    hgeo_m: float = 12.0
    r_mh2: float = 4.60e-4
    eta: float = 0.62
    pnom_kw: float = 15.0
    inom_a: float = 28.0
    imag_share: float = 0.30
    loss_share: float = 0.12


@dataclass(frozen=True)
class SimCfg:
    """ST_SimCfg: параметры модели (то, что нужно эталону)."""

    tank_area_m2: float = 12.0
    level_overflow_m: float = 4.60
    level_init_m: float = 1.20
    inflow_avg_m3h: float = 70.0
    daily_profile: tuple[float, ...] = DAILY_PROFILE
    seed: int = 20261016
    storms_per_day_max: int = 2
    storm_peak_min_m3h: float = 100.0
    storm_peak_max_m3h: float = 250.0
    storm_min_ms: int = 20 * 60 * 1000
    storm_max_ms: int = 90 * 60 * 1000
    pump: PumpCfg = field(default_factory=PumpCfg)


# --- насосы и сеть ---------------------------------------------------------------------------------


def pump_current(flow_m3h: float, head_m: float, speed: float, cfg: PumpCfg) -> float:
    """F_PumpCurrent: ток двигателя, А. Без вращения — 0.

    P_hyd = ρ·g·(q/3600)·H/1000; потребляемая P = max(P_hyd/η, rLossShare·Pnom·s³) — потери на
    холостом ходу не меньше нуля подачи (DESIGN 11.2); I = imag·Inom·s + (1 − imag)·Inom·P/Pnom.
    """
    if speed <= 0.0:
        return 0.0
    p_hyd_kw = RHO_KGM3 * G_MPS2 * (max(flow_m3h, 0.0) / S_PER_H) * max(head_m, 0.0) / W_PER_KW
    p_loss_kw = cfg.loss_share * cfg.pnom_kw * speed**3
    p_kw = max(p_hyd_kw / cfg.eta, p_loss_kw)
    return cfg.imag_share * cfg.inom_a * speed + (1.0 - cfg.imag_share) * cfg.inom_a * p_kw / cfg.pnom_kw


@dataclass(frozen=True)
class HydraulicPoint:
    """Рабочая точка: напор сети, подачи, токи, давление PT201."""

    head_m: float
    flows_m3h: tuple[float, ...]
    currents_a: tuple[float, ...]
    pressure_bar: float

    @property
    def flow_m3h(self) -> float:
        return sum(self.flows_m3h)


def _solve_head(
    speeds: Sequence[float],
    active: Sequence[bool],
    k_eff: Sequence[float],
    level_m: float,
    cfg: PumpCfg,
    iterations: int,
) -> tuple[float, list[float]]:
    """Бисекция по напору H на [Hgeo − h, max(H0·s²)]: подача насоса при H — √((H0·s² − H)/k)."""
    h_static = cfg.hgeo_m - level_m
    shutoff = [cfg.h0_m * s * s if a else 0.0 for s, a in zip(speeds, active, strict=True)]

    def flows_at(head: float) -> list[float]:
        return [
            math.sqrt((h0s2 - head) / k) if a and h0s2 > head else 0.0
            for h0s2, k, a in zip(shutoff, k_eff, active, strict=True)
        ]

    h_max = max(shutoff, default=0.0)
    if h_max <= h_static:
        return h_static, [0.0] * len(speeds)
    lo, hi = h_static, h_max
    for _ in range(iterations):
        mid = 0.5 * (lo + hi)
        total = sum(flows_at(mid))
        if h_static + cfg.r_mh2 * total * total > mid:
            lo = mid
        else:
            hi = mid
    head = 0.5 * (lo + hi)
    return head, flows_at(head)


def hydraulic_point(
    speeds: Sequence[float],
    level_m: float,
    cfg: PumpCfg | None = None,
    air_lock: Sequence[bool] | None = None,
    clog: Sequence[bool] | None = None,
    iterations: int = 100,
) -> HydraulicPoint:
    """FB_HydraulicSolver: насосы со скоростями s = f/50 Гц на общую сеть при уровне h.

    Сухой ход насоса — подача 0; засор — крутизна ×6,25, ток ×1,3 к току той же сети без засора;
    уровень ниже SIM_PUMP_INTAKE_M — все подачи 0. ``iterations`` = 30 повторяет ПЛК; эталон по
    умолчанию считает точнее (100), разница — меньше допусков тестов.
    """
    cfg = cfg or PumpCfg()
    n = len(speeds)
    air = list(air_lock) if air_lock is not None else [False] * n
    clg = list(clog) if clog is not None else [False] * n
    intake_dry = level_m < PUMP_INTAKE_M
    active = [s > 0.0 and not a and not intake_dry for s, a in zip(speeds, air, strict=True)]
    k_clog = [cfg.k_mh2 * (CLOG_K_FACTOR if c else 1.0) for c in clg]
    head, flows = _solve_head(speeds, active, k_clog, level_m, cfg, iterations)
    currents = [pump_current(q, head, s, cfg) for q, s in zip(flows, speeds, strict=True)]
    if any(c and not a for c, a in zip(clg, air, strict=True)):
        head_u, flows_u = _solve_head(speeds, active, [cfg.k_mh2] * n, level_m, cfg, iterations)
        for i in range(n):
            if clg[i] and not air[i]:
                currents[i] = CLOG_I_FACTOR * pump_current(flows_u[i], head_u, speeds[i], cfg)
    pressure = RHO_KGM3 * G_MPS2 * (head + level_m) / PA_PER_BAR
    return HydraulicPoint(head, tuple(flows), tuple(currents), pressure)


def equilibrium_level(speeds: Sequence[float], inflow_m3h: float, cfg: PumpCfg | None = None) -> float:
    """Уровень, при котором подача насосов равна притоку (бисекция по уровню на [0,3; 4,6])."""
    cfg = cfg or PumpCfg()
    lo, hi = PUMP_INTAKE_M, 4.60
    for _ in range(80):
        mid = 0.5 * (lo + hi)
        if hydraulic_point(speeds, mid, cfg).flow_m3h < inflow_m3h:
            lo = mid
        else:
            hi = mid
    return 0.5 * (lo + hi)


def ma_of(value: float, range_hi: float, range_lo: float = 0.0) -> float:
    """Ток датчика 4–20 мА (FB_AnalogSensorSim без инъекции), насыщение по NE 43: 3,8…20,5 мА."""
    ma = 4.0 + 16.0 * (value - range_lo) / (range_hi - range_lo)
    return min(max(ma, 3.8), 20.5)


# --- приток и ливни --------------------------------------------------------------------------------


def inflow_factor(tod_h: float, profile: Sequence[float] = DAILY_PROFILE) -> float:
    """FB_InflowProfile: линейная интерполяция точек профиля (точка — начало часа), полночь — по кругу."""
    n = len(profile)
    tod = tod_h % HOURS_PER_DAY
    pos = tod * n / HOURS_PER_DAY
    i = min(int(pos), n - 1)
    frac = pos - i
    return profile[i] + (profile[(i + 1) % n] - profile[i]) * frac


def xorshift32(x: int) -> int:
    """F_Xorshift32: x ^= x << 13; x ^= x >> 17; x ^= x << 5 (32 бит)."""
    x ^= (x << 13) & MASK32
    x ^= x >> 17
    x ^= (x << 5) & MASK32
    return x & MASK32


@dataclass(frozen=True)
class Storm:
    """ST_StormEvent: начало в сутках, ч; длительность, мс; пик, м³/ч."""

    start_h: float
    duration_ms: int
    peak_m3h: float


def storms_for_day(day: int, cfg: SimCfg | None = None) -> list[Storm]:
    """FB_StormGenerator.GenerateDay: ливни суток ``day`` (DESIGN 11.2).

    x0 = seed XOR (day · 16#9E3779B9) mod 2³²; каждое равномерное u — следующий шаг xorshift.
    Порядок выборок: число ливней, затем для каждого — начало, длительность, пик.
    """
    cfg = cfg or SimCfg()
    x = (cfg.seed ^ ((day * SEED_DAY_MUL) & MASK32)) & MASK32
    if x == 0:
        x = XS_ZERO_STATE

    def draw() -> float:
        nonlocal x
        x = xorshift32(x)
        return (x & U24_MASK) / U24_SCALE

    n_max = cfg.storms_per_day_max
    count = min(int(draw() * (n_max + 1)), n_max)
    storms: list[Storm] = []
    for _ in range(count):
        start_h = draw() * HOURS_PER_DAY
        dur_ms = math.floor(cfg.storm_min_ms + draw() * (cfg.storm_max_ms - cfg.storm_min_ms) + 0.5)
        peak = cfg.storm_peak_min_m3h + draw() * (cfg.storm_peak_max_m3h - cfg.storm_peak_min_m3h)
        storms.append(Storm(start_h, dur_ms, peak))
    return storms


def storm_shape(tau_s: float, duration_s: float, peak_m3h: float) -> float:
    """Трапеция ливня: рост 15 %, полка 50 %, спад 35 % длительности; вне [0, D) — 0."""
    if duration_s <= 0.0 or tau_s < 0.0 or tau_s >= duration_s:
        return 0.0
    rise = STORM_RISE_SHARE * duration_s
    fall_start = (1.0 - STORM_FALL_SHARE) * duration_s
    if tau_s < rise:
        return peak_m3h * tau_s / rise
    if tau_s < fall_start:
        return peak_m3h
    return peak_m3h * (duration_s - tau_s) / (STORM_FALL_SHARE * duration_s)


def storm_inflow(clock_h: float, cfg: SimCfg | None = None) -> float:
    """Приток ливней в момент ``clock_h`` (часы модели от полуночи суток 0): ливни суток и предыдущих."""
    cfg = cfg or SimCfg()
    day = int(clock_h // HOURS_PER_DAY)
    total = 0.0
    for d in (day - 1, day):
        if d < 0:
            continue
        for s in storms_for_day(d, cfg):
            tau_s = (clock_h - (d * HOURS_PER_DAY + s.start_h)) * S_PER_H
            total += storm_shape(tau_s, s.duration_ms / 1000.0, s.peak_m3h)
    return total


def inflow(clock_h: float, cfg: SimCfg | None = None) -> float:
    """Приток по профилю и ливням: rInflowAvg_m3h · f(tod) + Q_storm."""
    cfg = cfg or SimCfg()
    return cfg.inflow_avg_m3h * inflow_factor(clock_h, cfg.daily_profile) + storm_inflow(clock_h, cfg)


# --- резервуар -------------------------------------------------------------------------------------


@dataclass
class Tank:
    """FB_TankModel: dV = (Qin − Qout)·dt/3600, h = V/S; перелив ограничивает уровень и копит время."""

    level_m: float
    area_m2: float = 12.0
    overflow_m: float = 4.60
    overflow_s: float = 0.0

    def step(self, inflow_m3h: float, outflow_m3h: float, dt_s: float) -> None:
        if dt_s <= 0.0:
            return
        if self.level_m < PUMP_INTAKE_M:
            outflow_m3h = 0.0
        self.level_m += (inflow_m3h - outflow_m3h) * dt_s / S_PER_H / self.area_m2
        if self.level_m >= self.overflow_m:
            if inflow_m3h > outflow_m3h:
                self.overflow_s += dt_s
            self.level_m = self.overflow_m
        self.level_m = max(self.level_m, 0.0)


# --- упрощённая станция (только для оценок документов) ---------------------------------------------


@dataclass
class SteppedStation:
    """04 §6 и §10.2 без ПЧ и задержек насосов: уровни с выдержкой 5 с, аварийный режим ≥ 4,0 м 3 с.

    Насосы выходят на 100 % сразу. Это оценка для документов; поведение станции проверяют
    интеграционные тесты и сценарии ПМИ.
    """

    stop_m: float = 1.00
    start_lead_m: float = 1.60
    stop_assist_m: float = 1.40
    start_assist_m: float = 2.40
    confirm_s: float = 5.0
    hh_m: float = 4.00
    hh_delay_s: float = 3.0
    h_release_m: float = 3.50
    duty_max: int = 2
    required: int = 0
    emergency: bool = False
    _timer: dict[str, float] = field(default_factory=dict)

    def _held(self, name: str, cond: bool, delay_s: float, dt_s: float) -> bool:
        t = self._timer.get(name, 0.0) + dt_s if cond else 0.0
        self._timer[name] = t
        return cond and t >= delay_s

    def step(self, level_m: float, dt_s: float) -> int:
        if self._held("hh", level_m >= self.hh_m, self.hh_delay_s, dt_s):
            self.emergency = True
        elif self.emergency and level_m < self.h_release_m:
            self.emergency = False
        up_lead = self._held("lead", level_m >= self.start_lead_m, self.confirm_s, dt_s)
        up_assist = self._held("assist", level_m >= self.start_assist_m, self.confirm_s, dt_s)
        down_assist = self._held("stop_assist", level_m <= self.stop_assist_m, self.confirm_s, dt_s)
        down_all = self._held("stop", level_m <= self.stop_m, self.confirm_s, dt_s)
        if down_all:
            self.required = 0
        elif self.required == 0 and up_lead:
            self.required = 1
        elif self.required == 1 and up_assist:
            self.required = min(2, self.duty_max)
        elif self.required >= 2 and down_assist:
            self.required = 1
        return 3 if self.emergency else self.required


@dataclass
class RunResult:
    """Итог прогона: моменты достижения уровней, максимум, перелив, пуски."""

    reached_s: dict[float, float]
    max_level_m: float
    overflow_s: float
    starts: int
    final_level_m: float


def run_closed_loop(
    duration_s: float,
    inflow_fn: Callable[[float], float],
    level0_m: float,
    marks_m: Sequence[float] = (),
    dt_s: float = 1.0,
    cfg: SimCfg | None = None,
) -> RunResult:
    """Резервуар + насосы на 100 % + упрощённая станция; ``inflow_fn(t_s)`` — приток."""
    cfg = cfg or SimCfg()
    tank = Tank(level0_m, cfg.tank_area_m2, cfg.level_overflow_m)
    station = SteppedStation()
    reached: dict[float, float] = {}
    max_level = level0_m
    starts = 0
    running = 0
    t = 0.0
    while t < duration_s:
        n = station.step(tank.level_m, dt_s)
        starts += max(n - running, 0)
        running = n
        point = hydraulic_point([1.0] * n + [0.0] * (3 - n), tank.level_m, cfg.pump, iterations=60)
        tank.step(inflow_fn(t), point.flow_m3h, dt_s)
        t += dt_s
        max_level = max(max_level, tank.level_m)
        for m in marks_m:
            if m not in reached and tank.level_m >= m:
                reached[m] = t
    return RunResult(reached, max_level, tank.overflow_s, starts, tank.level_m)


# --- сценарии --------------------------------------------------------------------------------------

Values = dict[str, float]


def _point_values(p: HydraulicPoint) -> Values:
    out: Values = {"head_m": p.head_m, "flow_m3h": p.flow_m3h, "pressure_bar": p.pressure_bar}
    for i, (q, c) in enumerate(zip(p.flows_m3h, p.currents_a, strict=True), start=1):
        out[f"q{i}_m3h"] = q
        out[f"i{i}_a"] = c
    return out


@functools.cache
def scenarios() -> dict[str, Values]:
    """Все эталонные значения: имя сценария → ключ → число (используются в тестах ST и pytest).

    Результат кэшируется (суточный прогон PMI-39 — секунды); вызывающий его не меняет.
    """
    pump = PumpCfg()
    cfg = SimCfg()
    out: dict[str, Values] = {}

    # гидравлика: DESIGN 11.3 (подбор характеристики), T9 ASSUMPTIONS
    out["hydraulic.one_pump_100"] = _point_values(hydraulic_point([1.0, 0.0, 0.0], 1.4, pump))
    out["hydraulic.one_pump_60"] = _point_values(hydraulic_point([0.6, 0.0, 0.0], 1.4, pump))
    out["hydraulic.one_pump_87"] = _point_values(hydraulic_point([0.87, 0.0, 0.0], 1.4, pump))
    out["hydraulic.two_pumps_75"] = _point_values(hydraulic_point([0.75, 0.75, 0.0], 1.4, pump))
    out["hydraulic.two_pumps_100"] = _point_values(hydraulic_point([1.0, 1.0, 0.0], 1.4, pump))
    out["hydraulic.three_pumps_100"] = _point_values(hydraulic_point([1.0, 1.0, 1.0], 1.4, pump))
    out["hydraulic.three_pumps_100_at_4m"] = _point_values(hydraulic_point([1.0, 1.0, 1.0], 4.0, pump))
    out["hydraulic.unequal_100_60"] = _point_values(hydraulic_point([1.0, 0.6, 0.0], 1.4, pump))
    out["hydraulic.unequal_100_90"] = _point_values(hydraulic_point([1.0, 0.9, 0.0], 1.4, pump))
    out["hydraulic.below_static_55"] = _point_values(hydraulic_point([0.55, 0.0, 0.0], 1.4, pump))
    out["hydraulic.stopped"] = _point_values(hydraulic_point([0.0, 0.0, 0.0], 1.4, pump))
    out["hydraulic.air_lock_100"] = _point_values(
        hydraulic_point([1.0, 0.0, 0.0], 1.4, pump, air_lock=[True, False, False])
    )
    out["hydraulic.clog_100"] = _point_values(hydraulic_point([1.0, 0.0, 0.0], 1.4, pump, clog=[True, False, False]))
    out["hydraulic.intake_dry"] = _point_values(hydraulic_point([1.0, 0.0, 0.0], 0.25, pump))
    out["hydraulic.closed_valve_100"] = {"pressure_bar": RHO_KGM3 * G_MPS2 * (pump.h0_m + 1.4) / PA_PER_BAR}

    # установившееся состояние: один насос 87 %, приток 120 м³/ч
    h_eq = equilibrium_level([0.87, 0.0, 0.0], 120.0, pump)
    p_eq = hydraulic_point([0.87, 0.0, 0.0], h_eq, pump)
    out["steady.one_pump_87_inflow_120"] = {
        "level_m": h_eq,
        "flow_m3h": p_eq.flow_m3h,
        "pressure_bar": p_eq.pressure_bar,
        "pt201_ma": ma_of(p_eq.pressure_bar, 10.0),
        "ft202_ma": ma_of(p_eq.flow_m3h, 500.0),
        "lt101_ma": ma_of(h_eq, 5.0),
        "i1_a": p_eq.currents_a[0],
        "it_counts": round(p_eq.currents_a[0] * 10.0),
    }

    # резервуар
    out["tank.balance_60_10min"] = {"dlevel_m": 60.0 * (600.0 / S_PER_H) / cfg.tank_area_m2}
    out["tank.balance_30_10_1h"] = {"level_m": 1.2 + (30.0 - 10.0) * 1.0 / cfg.tank_area_m2}

    # приток
    out["inflow.profile"] = {
        "at_08h_m3h": cfg.inflow_avg_m3h * inflow_factor(8.0),
        "at_08h30_m3h": cfg.inflow_avg_m3h * inflow_factor(8.5),
        "at_23h30_factor": inflow_factor(23.5),
        "at_03h_m3h": cfg.inflow_avg_m3h * inflow_factor(3.0),
        "mean_factor": sum(inflow_factor(0.25 * i) for i in range(96)) / 96.0,
        "peak_m3h": cfg.inflow_avg_m3h * max(DAILY_PROFILE),
        "min_m3h": cfg.inflow_avg_m3h * min(DAILY_PROFILE),
    }

    # ливни для seed по умолчанию
    x1 = xorshift32(cfg.seed)
    out["xorshift.seed_default"] = {"x1": float(x1), "x2": float(xorshift32(x1))}
    out["xorshift.one"] = {"x1": float(xorshift32(1))}
    for day in range(3):
        st = storms_for_day(day, cfg)
        vals: Values = {"count": float(len(st))}
        for j, s in enumerate(st, start=1):
            vals[f"s{j}_start_h"] = s.start_h
            vals[f"s{j}_duration_ms"] = float(s.duration_ms)
            vals[f"s{j}_peak_m3h"] = s.peak_m3h
        out[f"storms.day{day}"] = vals
    # ливень через полночь: сутки 21 seed по умолчанию; приток в 00:15 суток 22
    midnight = next(s for s in storms_for_day(21, cfg) if s.start_h + s.duration_ms / 3.6e6 > HOURS_PER_DAY)
    out["storms.midnight_day21"] = {
        "start_h": midnight.start_h,
        "duration_ms": float(midnight.duration_ms),
        "peak_m3h": midnight.peak_m3h,
        "inflow_d22_00h15_m3h": storm_inflow(22 * HOURS_PER_DAY + 0.25, cfg),
        "day22_count": float(len(storms_for_day(22, cfg))),
    }
    # предел числа ливней: 10 в настройке → SIM_STORMS_MAX = 4; seed 0 — нулевое состояние заменяется
    cfg4 = replace(cfg, storms_per_day_max=4)
    out["storms.max4"] = {f"day{d}_count": float(len(storms_for_day(d, cfg4))) for d in range(3)}
    cfg0 = replace(cfg, seed=0, storms_per_day_max=4)
    out["storms.seed0_max4"] = {f"day{d}_count": float(len(storms_for_day(d, cfg0))) for d in range(6)}
    out["storms.shape_d1h_peak200"] = {
        "q_at_4m30s": storm_shape(270.0, 3600.0, 200.0),
        "q_at_9m": storm_shape(540.0, 3600.0, 200.0),
        "q_at_30m": storm_shape(1800.0, 3600.0, 200.0),
        "q_at_49m30s": storm_shape(2970.0, 3600.0, 200.0),
        "q_at_60m": storm_shape(3600.0, 3600.0, 200.0),
    }

    # PMI-20/24: приток 250 м³/ч от И0 (1,20 м), ступенчатое → аварийный режим
    r20 = run_closed_loop(3600.0, lambda _t: 250.0, cfg.level_init_m, marks_m=(4.0, 4.2, 4.4, 4.6))
    out["pmi20.inflow_250"] = {f"t_{m:.1f}m_min": r20.reached_s[m] / 60.0 for m in (4.0, 4.2, 4.4, 4.6)}

    # PMI-39: сутки по профилю и ливням (seed по умолчанию), упрощённая станция
    r39 = run_closed_loop(HOURS_PER_DAY * S_PER_H, lambda t: inflow(t / S_PER_H, cfg), cfg.level_init_m, dt_s=2.0)
    out["pmi39.day0_stepped"] = {
        "max_level_m": r39.max_level_m,
        "overflow_s": r39.overflow_s,
        "starts": float(r39.starts),
        "storm_max_inflow_m3h": max(inflow(i / 60.0, cfg) for i in range(24 * 60)),
    }
    return out


def default_sim_cfg() -> SimCfg:
    """Конфигурация по умолчанию (как ST_SimCfg); для тестов с изменёнными параметрами — ``replace``."""
    return replace(SimCfg())


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Эталон модели КНС-1 (DESIGN, раздел 11)")
    parser.add_argument("--json", action="store_true", help="вывести значения в JSON")
    args = parser.parse_args(argv)
    values = scenarios()
    if args.json:
        print(json.dumps(values, ensure_ascii=False, indent=2))
        return 0
    for name, vals in values.items():
        for key, val in vals.items():
            print(f"{name}.{key} = {val:.6f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
