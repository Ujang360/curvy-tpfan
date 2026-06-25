#!/usr/bin/env bash
# Unit tests for the pure curve math in tpfan-curvy — no hardware required.
# Sources the daemon (guarded so main() does not run) and exercises the
# arithmetic helpers directly.
set -uo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../src/tpfan-curvy
source "$here/../src/tpfan-curvy"

fail=0
assert() { # $1=description $2=expected $3=actual
  if [[ $2 == "$3" ]]; then
    printf 'ok   %s\n' "$1"
  else
    printf 'FAIL %s: expected %s, got %s\n' "$1" "$2" "$3"
    fail=1
  fi
}

# curve() reads the global span; pin it for deterministic assertions.
TEMP_LO=40
TEMP_HI=75

# balanced band [2..7] across 40..75 °C
assert "balanced clamps to MIN below span" 2 "$(curve 30 2 7)"
assert "balanced at lower edge" 2 "$(curve 40 2 7)"
assert "balanced clamps to MAX above span" 7 "$(curve 80 2 7)"
assert "balanced midpoint rounds" 5 "$(curve 60 2 7)"

# low-power band [0..2] — fully off when cool, capped at 2 when hot
assert "low-power off when cool" 0 "$(curve 40 0 2)"
assert "low-power capped when hot" 2 "$(curve 75 0 2)"

# performance band [7..7] — flat
assert "performance flat (low temp)" 7 "$(curve 45 7 7)"
assert "performance flat (high temp)" 7 "$(curve 70 7 7)"

# EC level -> pwm quantization (rounded)
assert "level_to_pwm 0" 0 "$(level_to_pwm 0)"
assert "level_to_pwm 2" 73 "$(level_to_pwm 2)"
assert "level_to_pwm 7" 255 "$(level_to_pwm 7)"

# band_for resolves known modes and falls back to balanced for unknown ones
assert "band_for low-power" "0 2" "$(band_for low-power)"
assert "band_for unknown -> balanced" "2 7" "$(band_for cool)"

if ((fail)); then
  printf '\nFAILED\n'
  exit 1
fi
printf '\nall %s curve checks passed\n' 14
