# Tuning

All configuration lives in `/etc/tpfan-curvy.conf` (shell-sourced). After any
change:

```sh
tpfan-curvy --check               # validate + preview, writes nothing
sudo systemctl restart tpfan-curvy
```

## Presets

`PRESET` sets the critical temperature, curve span, and hysteresis in one go.
Any explicit variable you set overrides the preset value.

| preset | `CRIT` | `TEMP_LO` | `TEMP_HI` | `HYST` |
|--------|--------|-----------|-----------|--------|
| `quiet` | 92 | 55 | 88 | 6 |
| `normal` | 90 | 48 | 82 | 5 |
| `aggressive` | 85 | 40 | 75 | 4 |

## Variables

| variable | meaning | default (normal) |
|----------|---------|------------------|
| `PRESET` | aggressiveness preset | `normal` |
| `MODE_SOURCE` | `platform_profile` or `ppd` | `platform_profile` |
| `POLL` | seconds between samples | `2` |
| `CRIT` | ≥ this temp → disengage (full speed), any mode | `90` |
| `CRIT_HYST` | resume curve only below `CRIT − CRIT_HYST` | `5` |
| `TEMP_LO` | at/below → band `MIN` | `48` |
| `TEMP_HI` | at/above → band `MAX` | `82` |
| `HYST` | downshift deadband °C (upshift is immediate) | `5` |
| `BAND[<mode>]` | EC level band `"MIN MAX"` for a power mode | see below |

## Bands

A power mode's fan never leaves its band. `BAND[<mode>]` is `"MIN MAX"` in EC
levels (0–7). Keys are the power-mode tokens:

```sh
BAND["performance"]="7 7"     # ~90-100%
BAND["balanced"]="2 7"        # ~25-100%
BAND["low-power"]="0 2"       # ~0-35%  (platform_profile battery mode)
BAND["power-saver"]="0 2"     # ppd battery mode (same intent as low-power)
```

Run `tpfan-curvy --check` to see the exact `platform_profile` choices your
machine exposes — some models use `quiet` / `cool` / `balanced-performance`
instead. Add a `BAND` entry for each; any mode without one falls back to the
`balanced` band.

## The curve

Within `[MIN, MAX]`, the EC level at temperature `t` is:

```
level(t) = MIN                                  if t ≤ TEMP_LO
         = MAX                                  if t ≥ TEMP_HI
         = round( MIN + (t − TEMP_LO) / (TEMP_HI − TEMP_LO) × (MAX − MIN) )
```

EC level → pwm (the EC quantises to 8 steps):

| level | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|-------|---|---|---|---|---|---|---|---|
| pwm | 0 | 36 | 73 | 109 | 146 | 182 | 219 | 255 |

## Hysteresis

The fan steps **up** the instant the curve calls for a higher level. It steps
**down** only once the temperature has fallen `HYST` °C below the level's
threshold, which prevents rapid oscillation between adjacent levels.

## Example: silent-on-battery, aggressive-on-AC

```sh
PRESET=aggressive
MODE_SOURCE=platform_profile
BAND["low-power"]="0 1"     # cap battery mode at level 1 (~14%)
BAND["performance"]="7 7"   # full band on AC
```

## Older ThinkPads (no platform_profile)

```sh
MODE_SOURCE=ppd             # poll power-profiles-daemon instead
BAND["power-saver"]="0 2"   # ppd's battery-mode token
```
