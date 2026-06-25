# Roadmap

## Distribution milestones

Packaging is the priority — the daemon is useful today, but reach depends on it
being installable the way each distro's users expect.

1. **AUR** (Arch, CachyOS, Manjaro) — `tpfan-curvy` package built from
   [`packaging/aur/PKGBUILD`](../packaging/aur). *In progress.*
2. **Debian / Ubuntu** — native `.deb` (`debian/` packaging), candidate PPA.
3. **RHEL / Fedora** — `.rpm` spec, candidate COPR.
4. **Others** — openSUSE (OBS), Gentoo overlay, Nix flake.

Each milestone reuses the same artifacts (binary, unit, modprobe conf, config);
only the packaging metadata and install hooks differ.

## Feature ideas (post-1.0, unordered)

- Broaden the tested-model matrix (community reports via `--check`).
- Smarter defaults per `platform_profile` choice set (auto-map `quiet`/`cool`).
- Optional per-mode curve spans (not just per-mode bands).
- GPU-temperature-weighted curve for dGPU-heavy ThinkPads.
- A `--once` mode for debugging (apply one tick and exit).

## Non-goals

- GUI / tray applet — this is a daemon; configuration is one file.
- Non-ThinkPad hardware — `fan2go` / `nbfc-linux` already cover generic laptops.
- Replacing `thinkfan` for static single-curve use — different problem.
