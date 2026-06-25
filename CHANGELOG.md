# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-06-26

Initial release.

### Added

- `tpfan-curvy` daemon: binds a per-power-mode fan band to the active power
  profile and runs a temperature curve within each band.
- Mode source from the kernel ACPI `platform_profile` (desktop- and
  daemon-agnostic), with a `power-profiles-daemon` fallback (`MODE_SOURCE=ppd`)
  for pre-DYTC ThinkPads.
- Vendor-agnostic temperature reading: ThinkPad EC sensors plus `coretemp`
  (Intel) and/or `k10temp` (AMD), hottest wins.
- Aggressiveness presets: `quiet`, `normal` (default), `aggressive`.
- Directional hysteresis (immediate upshift, deadbanded downshift).
- Hard thermal override: disengage (full speed) at/above the critical
  temperature in every mode, with recovery hysteresis.
- Fail-safe: EC automatic control restored on every exit path; systemd
  `Type=notify` watchdog with `Restart=always`.
- Config validation; the daemon refuses to run an invalid curve.
- `--check` self-test: prints resolved sensors, config, and the curve table
  without writing to hardware.
- External configuration at `/etc/tpfan-curvy.conf`.
- Hardened systemd unit, `just` task runner, unit tests for the curve math,
  and CI (shellcheck + shfmt + tests).

[Unreleased]: https://github.com/Ujang360/curvy-tpfan/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/Ujang360/curvy-tpfan/releases/tag/v0.1.0
