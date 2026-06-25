# Supported models

curvy-tpfan targets any ThinkPad whose `thinkpad_acpi` driver exposes a
controllable fan (`pwm1`) and which reports a power mode via
`platform_profile` or `power-profiles-daemon`. That covers most of the modern
lineup, Intel and AMD alike. This page tracks models people have actually run
it on.

## Tested

| Model | Machine type | CPU | dGPU | mode source | status | reporter |
|-------|--------------|-----|------|-------------|--------|----------|
| ThinkPad T15p Gen 1 | 20TMS0FL06 | Intel i7-10750H | yes | `platform_profile` | ✅ working | [@Ujang360](https://github.com/Ujang360) |

## Expected to work (untested)

Any ThinkPad with `thinkpad_acpi` + `platform_profile`, including:

- T/P/X/L/E series, 2019 onward (DYTC `platform_profile`).
- AMD ThinkPads (T14/T16/P14s/Z13 AMD) — temperatures read from `k10temp` plus
  the ThinkPad EC sensors.
- Dual-fan P-series — `thinkpad_acpi` still exposes a single `pwm1` that drives
  both fans together.

Older ThinkPads without `platform_profile` can use `MODE_SOURCE=ppd`.

## Add your model

1. Install and reboot, then run:

   ```sh
   tpfan-curvy --check
   ```

2. Open an issue using the **Model support report** template and paste:
   - the `--check` output,
   - `cat /sys/class/dmi/id/product_name /sys/class/dmi/id/product_version`,
   - `cat /sys/firmware/acpi/platform_profile_choices` (if present).

If `--check` resolved your thinkpad hwmon and sensors and the curve table looks
right, it almost certainly works — the report just lets us add you to the table
and ship better defaults for your profile names.

## Known caveats

- Some models expose `platform_profile` choices other than
  `low-power`/`balanced`/`performance` (e.g. `quiet`, `cool`,
  `balanced-performance`). Add a `BAND[<name>]` for each in your config; unknown
  modes fall back to the `balanced` band. See [TUNING](TUNING.md).
- Pre-DYTC ThinkPads have no `platform_profile`; use `MODE_SOURCE=ppd`.
