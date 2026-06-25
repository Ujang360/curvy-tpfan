# curvy-tpfan — task runner (https://github.com/casey/just)
# Run `just` with no arguments to list recipes.

set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

prefix      := "/usr"
destdir     := ""
bindir      := destdir + prefix + "/bin"
confdir     := destdir + "/etc"
unitdir     := destdir + "/usr/lib/systemd/system"
modprobedir := destdir + "/etc/modprobe.d"

# List available recipes
default:
    @just --list

# Static analysis (shellcheck)
lint:
    shellcheck src/tpfan-curvy tests/curve_test.sh

# Format shell sources in place (shfmt)
fmt:
    shfmt -i 2 -ci -w src/tpfan-curvy tests/curve_test.sh

# Verify formatting without writing — used by CI
fmt-check:
    shfmt -i 2 -ci -d src/tpfan-curvy tests/curve_test.sh

# Bash syntax check
syntax:
    bash -n src/tpfan-curvy

# Unit-test the curve math (no hardware required)
test:
    bash tests/curve_test.sh

# Print resolved sensors + curve table for THIS machine (writes nothing)
check:
    bash src/tpfan-curvy --check

# Everything CI runs
ci: fmt-check lint syntax test

# Stage files into DESTDIR (no privilege needed; used by packaging and `install`)
install-files:
    install -Dm0755 src/tpfan-curvy                "{{ bindir }}/tpfan-curvy"
    install -Dm0644 systemd/tpfan-curvy.service    "{{ unitdir }}/tpfan-curvy.service"
    install -Dm0644 modprobe.d/99-tpfan-curvy.conf "{{ modprobedir }}/99-tpfan-curvy.conf"
    install -Dm0644 config/tpfan-curvy.conf        "{{ confdir }}/tpfan-curvy.conf"

# Install onto this system (uses sudo when not already root)
install:
    #!/usr/bin/env bash
    set -euo pipefail
    sudo=""; [[ $EUID -eq 0 ]] || sudo="sudo"
    $sudo install -Dm0755 src/tpfan-curvy                 "{{ bindir }}/tpfan-curvy"
    $sudo install -Dm0644 systemd/tpfan-curvy.service     "{{ unitdir }}/tpfan-curvy.service"
    $sudo install -Dm0644 modprobe.d/99-tpfan-curvy.conf  "{{ modprobedir }}/99-tpfan-curvy.conf"
    if [[ ! -e "{{ confdir }}/tpfan-curvy.conf" ]]; then
      $sudo install -Dm0644 config/tpfan-curvy.conf       "{{ confdir }}/tpfan-curvy.conf"
    fi
    $sudo systemctl daemon-reload
    echo
    echo "Installed. Next:"
    echo "  1) reboot   (loads thinkpad_acpi fan_control=1)"
    echo "  2) tpfan-curvy --check        # confirm sensors + curve"
    echo "  3) sudo systemctl enable --now tpfan-curvy"

# Remove from this system (preserves /etc/tpfan-curvy.conf)
uninstall:
    #!/usr/bin/env bash
    set -euo pipefail
    sudo=""; [[ $EUID -eq 0 ]] || sudo="sudo"
    $sudo systemctl disable --now tpfan-curvy.service 2>/dev/null || true
    $sudo rm -f "{{ bindir }}/tpfan-curvy" \
                "{{ unitdir }}/tpfan-curvy.service" \
                "{{ modprobedir }}/99-tpfan-curvy.conf"
    $sudo systemctl daemon-reload
    echo "Removed (kept {{ confdir }}/tpfan-curvy.conf). Reboot to drop fan_control=1."
