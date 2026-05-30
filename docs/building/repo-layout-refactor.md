# Repository Layout Refactor

This document records the intended direction for folder-structure-only cleanup.
The goal is to make the first path segment answer "what kind of thing is this?"
instead of preserving only historical component names.

## Current direction

Use these ownership buckets for new moves:

| Area | Purpose |
| --- | --- |
| `src/runtime` | Runtime implementation currently rooted in `dxaml/xcp`. |
| `src/controls` | WinUI controls implementation currently rooted in `controls/dev`. |
| `src/compiler` | XAML compiler source, build tasks, compiler targets, and compiler-local tools. |
| `tests` | Runtime, controls, compiler, sample, and Helix test assets. |
| `eng` | Shared build, packaging, versioning, signing, and pipeline infrastructure. |
| `tools` | Human- and CI-invoked repo tools that are not part of product source. |
| `generated` | Checked-in generated output, visual baselines, and large derived assets. |

## First completed move

`src/XamlCompiler` was moved to `src/compiler`. This is intentionally scoped:
the compiler is a relatively self-contained source area, and moving it first
proves the path-update pattern before touching `dxaml` or `controls`.

## Migration rules

- Keep PRs mechanical. Do not mix folder moves with behavior changes.
- Update solution files, project files, scripts, docs, and skill metadata in the
  same change as the move.
- Preserve names that are product identities, such as `XamlCompiler.exe` and
  `Microsoft.UI.Xaml.Markup.Compiler`; only path segments should change.
- Prefer root-level properties such as `$(ProjectRoot)` over hard-coded paths
  when touching MSBuild files.
- Move generated or baseline assets only after their generation/update workflow
  is documented and verified.

## Future candidates

1. Move compiler regression tests from `src/compiler/Tests` to `tests/compiler`
   after the compiler solutions and test scripts can tolerate the new relative
   path.
2. Move Helix and top-level test scripts under `tests/infra`.
3. Move `controls/dev/Generated`, IntelliSense XML, and visual baselines into a
   generated-assets area with clear update tooling.
4. Move `controls/dev` to `src/controls` after the controls solution path usage
   is audited.
5. Move `dxaml/xcp` to `src/runtime` last, because it has the broadest MSBuild
   and native project surface.
