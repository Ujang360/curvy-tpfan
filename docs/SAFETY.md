# Safety

curvy-tpfan takes **manual control of your ThinkPad's cooling**. Read this
before enabling it, especially on a model not in the
[tested matrix](SUPPORTED-MODELS.md).

## The risk

When the daemon is running, the embedded controller's automatic fan management
is overridden by the curve you configure. A curve that is too lazy — or a
`low-power` band that holds the fan low under sustained load — can let the CPU
or GPU run hot and thermal-throttle. On hardware where the thermal sensors the
daemon reads do not track the hottest component, a bad config could in principle
allow damaging temperatures.

## How the design mitigates it

- **Critical override (always on).** At or above the critical temperature the
  fan **disengages** to full speed regardless of mode, and holds until the
  temperature drops below `CRIT − CRIT_HYST`. This is not optional and not
  mode-dependent.
- **Fail-safe restore.** Every exit path — clean stop, crash, `SIGKILL`,
  invalid config, watchdog timeout — returns the fan to the EC's automatic
  control (`pwm1_enable=2`). The daemon traps signals and the systemd unit's
  `ExecStopPost` re-asserts it independently.
- **Watchdog.** The unit is `Type=notify` with `WatchdogSec=15`. A hung daemon
  is killed and restarted rather than leaving the fan pinned at its last manual
  level.
- **Config validation.** Invalid values (bad ranges, `CRIT ≤ TEMP_HI`,
  out-of-range bands) cause the daemon to refuse to start and fall back to EC
  auto, rather than running a nonsensical curve.
- **Conservative defaults.** The shipped `normal` preset (critical 90 °C, curve
  48 → 82 °C) is intentionally tame. Aggressive tuning is opt-in.

## Your responsibilities

1. **Run `tpfan-curvy --check` first.** Confirm it found your thinkpad hwmon and
   real temperature sensors, and that the curve table looks sane. It writes
   nothing to hardware.
2. **Watch the first load.** After enabling, run a stressor and watch
   `watch -n1 sensors` (or `tpfan-curvy --check` repeatedly). Confirm the fan
   responds and temperatures stay well under throttle.
3. **Do not set a `low-power` band you would not tolerate under load** unless
   you trust the critical override for your workload.
4. **Keep `CRIT` below your CPU's throttle point** with margin (the default
   leaves ~10 °C).

## Disclaimer

This software is provided "as is", without warranty of any kind, as stated in
the [LICENSE](../LICENSE). Enabling manual fan control is done at your own risk.
If anything looks wrong in `--check`, do not enable the service — open an issue
with the `--check` output instead.
