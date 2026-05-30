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

## Compiler entry points

Compiler-specific build entry points should live with the compiler source when
their MSBuild import behavior allows it. `XamlCompilerPrerequisites.sln` now
lives under `src/compiler` alongside `XamlCompiler.sln` and the compiler
projects it orchestrates. `XamlCompilerPublic.csproj` remains at the repo root
until its `Directory.Build.props` behavior can be isolated.

## Compiler test entry points

Compiler-specific test entry points now live under `tests/compiler`.
`XamlCompilerTests.sln`, `runtests.cmd`, and `copynewmasters.cmd` moved there
so the source tree can keep compiler implementation separate from compiler test
orchestration. The compiler source solution references unit-test projects
through `tests/compiler`.

## Shared test infrastructure

The top-level test payload entry points and Helix orchestration now live under
`tests/infra`. `CreateTestPayload.cmd`, `CreateTestPayload.ps1`, their
companion scripts, and the `Helix` project/scripts tree moved there so
repo-level test orchestration is grouped with other separated test assets.

## Generated controls sources

Checked-in generated dependency-property sources for controls now live under
`generated/controls/dependencyproperties`. Build inputs and authoring tools
refer to this location through `$(MUXControlsGeneratedSourceDir)` so generated
output is separated from handwritten controls source.

## Generated package IntelliSense

Checked-in package IntelliSense XML now lives under
`generated/packaging/intellisense`. The package project consumes that directory
through `$(IntellisenseFolder)`, while the docs-team drop input stays under
`packaging/Intellisense/drop`.

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

1. Move compiler test project assets into `tests/compiler` once they are
   present in the checkout and their generation/update workflows are verified.
2. Move visual baselines into the generated-assets area with clear update
   tooling.
3. Move `controls/dev` to `src/controls` after the controls solution path usage
   is audited.
4. Move `dxaml/xcp` to `src/runtime` last, because it has the broadest MSBuild
   and native project surface.
