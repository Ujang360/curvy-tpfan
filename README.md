# curvy-tpfan

[![CI](https://github.com/Ujang360/curvy-tpfan/actions/workflows/ci.yml/badge.svg)](https://github.com/Ujang360/curvy-tpfan/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A small, dependency-light fan-control daemon for ThinkPads that binds the fan
curve to the **active power profile**. Performance, balanced, and battery modes
each get their own fan band; the curve moves the fan within that band by
temperature, with hysteresis and a hard thermal safety override.

```
mode         fan band         behaviour
performance  ~90–100%         runs the fan high; cool and quiet-be-damned
balanced     ~25–100%         curve ramps with temperature
low-power    ~0–35%           near-silent; fan may stop entirely when cool
any mode     DISENGAGE        ≥ critical temp → full speed, no exceptions
```

## Why this exists

[`thinkfan`](https://github.com/vmatare/thinkfan), `zcfan`, `fan2go`, and
`nbfc-linux` are all good, but none of them tie the curve to your power profile
— they run a single static curve. curvy-tpfan's one job is **a different fan
band per power mode**, plus a non-negotiable disengage-at-critical safety net.
If you switch to battery and want the machine near-silent, then switch to
performance and want maximum airflow, this does that automatically.

## How it works

- **Mode source** — reads the kernel ACPI `platform_profile`
  (`/sys/firmware/acpi/platform_profile`). That's the single source of truth
  that `power-profiles-daemon`, `tuned`, GNOME, KDE, and `asusctl` all write
  to, so curvy-tpfan is **not coupled to any desktop or power daemon**. Older
  ThinkPads without that interface can poll `power-profiles-daemon` instead
  (`MODE_SOURCE=ppd`).
- **Temperature** — the hottest of the ThinkPad EC's own sensors plus
  `coretemp` (Intel) or `k10temp` (AMD). Vendor-agnostic.
- **The curve** — within a mode's band `[MIN, MAX]` (EC levels 0–7), the fan
  level rises linearly from `MIN` at `TEMP_LO` to `MAX` at `TEMP_HI`.
- **Hysteresis** — ramps **up immediately** (safety), steps **down** only after
  the temperature falls a few degrees past the threshold (no oscillation).
- **Critical override** — at/above the critical temperature the fan
  **disengages** (EC full speed, beyond level 7) regardless of mode, and holds
  until the temperature recovers.
- **Fails safe** — every exit path (clean stop, crash, kill, watchdog timeout)
  hands the fan back to the EC's automatic control. A `systemd` watchdog
  restarts a hung daemon rather than leaving the fan stuck.

### Granularity

`thinkpad_acpi` exposes **8 fan levels (0–7)**, not continuous PWM, so bands
quantise to ~14% steps:

| level | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | disengage |
|-------|---|---|---|---|---|---|---|---|-----------|
| pwm   | 0 | 36 | 73 | 109 | 146 | 182 | 219 | 255 | full |
| ~%    | 0 | 14 | 28 | 43 | 57 | 71 | 86 | 100 | >100 |

## Requirements

- A ThinkPad with the `thinkpad_acpi` kernel module (essentially all of them).
- `/sys/firmware/acpi/platform_profile` (most ThinkPads from ~2019 on) **or**
  `power-profiles-daemon` for the `ppd` fallback.
- `systemd`, `bash` ≥ 4.
- Manual fan control enabled: `options thinkpad_acpi fan_control=1` (the
  installer drops this in `/etc/modprobe.d`; it needs one reboot).

## Install

```sh
git clone https://github.com/Ujang360/curvy-tpfan
cd curvy-tpfan
just install          # installs binary, unit, modprobe conf, default config
sudo reboot           # loads thinkpad_acpi fan_control=1
tpfan-curvy --check   # confirm sensors + curve table look right for your model
sudo systemctl enable --now tpfan-curvy
```

> The installer does **not** auto-enable the service. Reboot, run `--check` to
> confirm it resolved your hardware correctly, then enable it. See
> [SAFETY](docs/SAFETY.md) before running on an untested model.

No `just`? It is a one-file task runner; the recipes are short — read the
[`Justfile`](Justfile) and run the three `install` commands by hand.

## Configure

Edit `/etc/tpfan-curvy.conf`, then `sudo systemctl restart tpfan-curvy`.

Pick an aggressiveness **preset**:

| preset | critical | curve span | hysteresis |
|--------|----------|------------|------------|
| `quiet` | 92 °C | 55 → 88 °C | 6 |
| `normal` (default) | 90 °C | 48 → 82 °C | 5 |
| `aggressive` | 85 °C | 40 → 75 °C | 4 |

Override any individual value or per-mode band below the preset. Full reference:
[docs/TUNING.md](docs/TUNING.md). Validate any change without touching the fan:

```sh
tpfan-curvy --check
```

## Safety

This daemon takes **manual control of cooling**. Misconfiguration can let the
machine run hot. The design mitigates this (disengage override, fail-safe
restore, watchdog), but you are responsible for the curve you set. Read
[docs/SAFETY.md](docs/SAFETY.md). Battery (`low-power`) mode can stop the fan
entirely when cool — the critical override is what keeps that safe under load.

## Supported models

Tested matrix and how to report yours: [docs/SUPPORTED-MODELS.md](docs/SUPPORTED-MODELS.md).

## Uninstall

```sh
just uninstall        # keeps /etc/tpfan-curvy.conf; reboot to drop fan_control=1
```

## Development

```sh
just            # list recipes
just ci         # fmt-check + shellcheck + syntax + unit tests
just check      # resolved sensors + curve table for this machine
```

See [CONTRIBUTING.md](CONTRIBUTING.md). Roadmap (AUR → Debian → RHEL → …):
[docs/ROADMAP.md](docs/ROADMAP.md).

## License

[MIT](LICENSE) © Aditya Kresna ([@Ujang360](https://github.com/Ujang360))
