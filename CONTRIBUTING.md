# Contributing

Thanks for helping. Bug reports, model-support reports, and patches are all
welcome.

## Reporting a model

The most useful contribution is confirming (or fixing) support for a ThinkPad.
Install, reboot, and open an issue with the **Model support report** template
containing your `tpfan-curvy --check` output. See
[docs/SUPPORTED-MODELS.md](docs/SUPPORTED-MODELS.md).

## Development setup

You need `bash`, `just`, `shellcheck`, and `shfmt`.

```sh
just            # list recipes
just ci         # what CI runs: fmt-check + shellcheck + syntax + unit tests
just fmt        # auto-format shell sources
just check      # resolved sensors + curve table for your machine (no writes)
```

CI runs `just ci` on every push and PR; it must pass.

## Code standards

- **Shell:** bash, `shellcheck`-clean (config in `.shellcheckrc`), formatted
  with `shfmt -i 2 -ci` (run `just fmt`).
- **Quote associative-array keys** (`BAND["low-power"]`). Unquoted, `shfmt`
  parses the `-` as arithmetic and corrupts the subscript — there is a comment
  in `src/tpfan-curvy` guarding this; do not undo it.
- **Pure logic is testable.** The daemon is source-guarded so `tests/` can pull
  in functions without running `main()`. Add a case to `tests/curve_test.sh` for
  any change to the curve math.
- **Safety first.** Any change to fan-control paths must preserve the invariants
  in [docs/SAFETY.md](docs/SAFETY.md): disengage-at-critical, fail-safe restore
  on every exit, and config validation before the loop runs.

## Commits & PRs

- Keep commits focused; write a clear imperative subject.
- Update `CHANGELOG.md` (Unreleased section) for user-visible changes.
- Run `just ci` before opening the PR.

## License

By contributing you agree your contribution is licensed under the project's
[MIT License](LICENSE).
