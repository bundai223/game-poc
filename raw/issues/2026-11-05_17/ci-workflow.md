# Issue #17: pull request CI workflow

- Date: 2026-11-05
- Target: `bundai223/game-poc`, Issue #17
- Base: `0fe74cc` (`test: add Godot headless test foundation`)

## Confirmed facts

- Issue #17 requests pinned Godot setup, headless import, `make test`, Web export, and a downloadable artifact on pull requests.
- `.github/workflows/pages.yml` already downloads Godot 4.7.2 and its Web export templates, then uses `make import` and `make export-web` before deploying Pages.
- `Makefile` checks that Godot 4.7.2 and the GdUnit4 runner exist, then runs the tests under `tests/`.
- A separate `.github/workflows/ci.yml` was added for `pull_request` and manual dispatch. It uses the same Godot and template download URLs as the Pages workflow, then runs `make import`, `make test`, and `make export-web` in order. It uploads `build/web/` as `godot-web-build` for seven days.
- The Pages workflow was not changed.

## Verification

- Ruby Psych parsed `.github/workflows/ci.yml` successfully.
- On macOS with Godot 4.7.2, `make import` completed.
- On macOS with Godot 4.7.2, `make test` passed all 3 test cases.
- `make export-web` did not complete in this sandbox. Godot could not save its editor settings under `/Users/bundai223/Library/Application Support/Godot` and crashed. A CA certificate warning also appeared. This does not establish a workflow failure on Ubuntu.
- Linux execution and an actual GitHub Actions run remain unverified.
- `git diff --check` passed before this record was added.

## Decision

Keep PR verification separate from deployment. Reuse the existing Pages workflow's pinned downloads and existing Makefile targets. Upload the build with `actions/upload-artifact` so PR verification does not publish to Pages.

## Related files

- `.github/workflows/ci.yml`
- `.github/workflows/pages.yml`
- `Makefile`
- `README.md`
- `wiki/pages/infrastructure/Godot開発環境.md`
