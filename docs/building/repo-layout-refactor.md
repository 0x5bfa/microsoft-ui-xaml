# Repository Layout Refactor

This document records the intended direction for folder-structure-only cleanup.
The goal is to make the first path segment answer "what kind of thing is this?"
instead of preserving only historical component names.

## Current direction

Use these ownership buckets for new moves:

| Area | Purpose |
| --- | --- |
| `src/runtime` | Runtime implementation currently rooted in `dxaml/xcp`. |
| `src/controls` | WinUI controls implementation. |
| `src/compiler` | XAML compiler source, build tasks, compiler targets, and compiler-local tools. |
| `src/metadata` | Metadata composition projects that produce repo-local WinMD inputs. |
| `tests` | Runtime, controls, compiler, sample, and Helix test assets. |
| `eng` | Shared build, packaging, versioning, signing, and pipeline infrastructure. |
| `tools` | Human- and CI-invoked repo tools that are not part of product source. |
| `generated` | Checked-in generated output, visual baselines, and large derived assets. |
| `docs/specs` | Feature and API design specs with their local images and supporting files. |

## First completed move

`src/XamlCompiler` was moved to `src/compiler`. This is intentionally scoped:
the compiler is a relatively self-contained source area, and moving it first
proves the path-update pattern before touching `dxaml` or `controls`.

## Compiler entry points

Compiler-specific build entry points should live with the compiler source.
`XamlCompilerPrerequisites.sln` now lives under `src/compiler` alongside
`XamlCompiler.sln`, `BuildTools.sln`, and the compiler projects it
orchestrates.

The OSS fallback project that downloads a public compiler package now lives at
`eng/XamlCompilerPublic.csproj`. It is build infrastructure rather than compiler
source, and keeping it under `eng` avoids importing the compiler-local
`Directory.Build.props`.

Compiler-local developer tools should live under `src/compiler/Tools` instead
of being nested inside product source or parser implementation folders. The
BindingPath `PathVisualizer` tool now lives there alongside the other
compiler-local tools.

## Compiler test entry points

Compiler-specific test entry points and support helpers now live under `tests/compiler`.
`XamlCompilerTests.sln`, `runtests.cmd`, and `copynewmasters.cmd` moved there
so the source tree can keep compiler implementation separate from compiler test
orchestration. The `FixMasters` helper used by `copynewmasters.cmd` now lives
under `tests/compiler/tools`. The compiler source solution references unit-test
projects through `tests/compiler`.

## Shared test infrastructure

The top-level test payload entry points and Helix orchestration now live under
`tests/infra`. `CreateTestPayload.cmd`, `CreateTestPayload.ps1`, their
companion scripts, and the `Helix` project/scripts tree moved there so
repo-level test orchestration is grouped with other separated test assets.

## Runtime test tools

Runtime-specific test tools should move out of `dxaml/test/tools` as their
references are isolated. `XmlValidation`, `MockDCompInjector`, `detours`, and
the test `codegen` helper now live under `tests/runtime/tools`. The `codegen`
command wrapper is co-located with that helper. The runtime solution keeps
project references to the project-based tools, and `DetoursPath` centralizes
the remaining detours import consumers.

## Runtime test packages

Runtime test AppX manifest inputs now live under `tests/runtime/packages/appx`.
They are test packaging assets rather than runtime source, and the runtime
solution references the package project from that test-owned location.

## Runtime AppAnalysis test support

AppAnalysis test support projects now live under `tests/runtime/appanalysis`.
`$(RuntimeTestPath)` and `$(AppAnalysisTestPath)` provide shared references for
runtime projects and AppAnalysis unit tests that consume those support projects.

## Runtime ad hoc test apps

Runtime ad hoc test applications now live under `tests/runtime/adhoc`. These
apps are test harnesses that consume built WinUI binaries, so keeping them with
runtime tests separates them from the runtime source tree.

## Runtime test themes

Runtime test theme dictionaries now live under `tests/runtime/themes`. They are
test payload assets and are binplaced into the runtime test theme folder from
that test-owned location.

Runtime test resource payload inputs now live under `tests/runtime/resources`.
The resource payload project keeps the same binplace layout while no longer
living under the legacy `dxaml/test/resources` tree.

Runtime test projects outside `dxaml/test` should use `$(InfraTestPath)` for
the remaining shared test infrastructure under `dxaml/test/infra`. The property
is defined with the other root folder paths so moved runtime tests do not need
to import `dxaml/test/Directory.Build.props`.

Runtime-specific infrastructure hosts should move under `tests/runtime/infra`
as their references are isolated. The .NET Core TAEF host moved first because it
only needs the runtime test build defaults and solution reference update. The
Invoker helper lives there too, with explicit imports back to the legacy runtime
build props and targets while `dxaml/xcp` remains in place. The MockDComp copy
shim also lives there because it only binplaces the WinUIDetails MockDComp DLL
for runtime tests. The RPC contract now lives there as the first shared native
runtime infra dependency, with source and generated-output paths exposed through
`$(RuntimeInfraTestPath)` and `$(RuntimeInfraTestObjPath)` for remaining legacy
infra consumers. Shared native test path aliases are available from the root
folder path props so moved runtime infra projects can still consume native test
headers. The native logging helper moved with the contract, so client infra can
include logging headers from the runtime infra source path while the client DLL
references the moved logging project directly. The native TAEF host app also
lives under runtime infra, while continuing to package the legacy private
infrastructure client from its current output location. The managed TAEF host
app lives next to it and uses shared root path properties for runtime and
private infrastructure project references.

## Runtime managed tests

Runtime managed test projects should move under `tests/runtime/managed` in
small groups. The media, AccessKeys, animation, common, enterprise, framework,
controls, foundation, Win32, Lifetime, and PGO managed test projects moved
first. The CompileBinding package assets also live in this test-owned tree even
though they are not a project.
`$(RuntimeManagedTestPath)` identifies the new home, and `$(ManagedTestPath)`
is now an alias for that location for compatibility with existing project
imports. The shared managed test props live in the new tree and reference the
common managed test sources through `$(RuntimeManagedTestPath)`. Non-SDK managed
test projects under the new tree explicitly import the local managed
`Directory.Build.props` before importing the shared managed test props. The PGO
test project imports the repo build props and targets by path because it is a
legacy project that does not consume the shared managed test props directly.

## Controls test infrastructure

Controls test infrastructure should live with the controls test projects it
supports. `AppTestAutomationHelpers` now lives under
`controls/test/testinfra` next to `MUXTestInfra` instead of under `Samples`, so
the sample-app tree stays focused on sample applications.

## Sample test automation

Sample test orchestration scripts now live under `tests/samples/scripts`. The
test payload still publishes them to the payload root, but their source location
now matches their role as test assets rather than sample applications.

## Initialization scripts

.NET SDK and runtime download helpers now live under `scripts/init`. They are
part of repository initialization rather than package construction, leaving the
`build` folder focused on packaging inputs and build-time transforms.

## Packaging inputs

NuGet package specs and package NOTICE content now live under
`packaging/nuspecs`, alongside the rest of the package build inputs. The
top-level package command still invokes the same helper script, but its source
location now reflects that it packs WinUI packaging output. The Edge runtime
dependency nuspec used by WebView2 test package updates also lives there.

## Build transforms

The fusion-manifest transform used by ad hoc app registration now lives under
`eng`, next to the target that invokes it. This removes the last checked-in
helper from the historical `build` folder.

## Package restore inputs

Repository-wide NuGet `packages.config` files now live under `eng/packages`.
They feed initialization and shared version extraction, so grouping them under
`eng` keeps dependency restore inputs with the rest of the build infrastructure.
`Packages.props` remains at the repository root because CentralPackageVersions
projects discover it by walking parent directories.

## PGO build inputs

PGO build configuration now lives under `eng/pgo`. The PGO props file is
imported by product projects and reads its local package restore config from
that folder, keeping top-level directories focused on source, tests, docs, and
repo entry points.

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

## Visual test baselines

Checked-in visual test baseline assets now live under
`generated/tests/visualbaselines`. The resource project stays under
`dxaml/test/resources/masters` so the existing test resource deployment layout
continues to expose `resources\masters` at runtime.

## Controls source

The WinUI controls implementation now lives under `src/controls`. The
`controls` tree remains the home for controls solution files, IDL, tests, and
authoring tools. Shared MSBuild entry points use `$(MUXControlsSourceRoot)` so
those support projects can reference controls source without reintroducing the
old `controls/dev` path segment.

## Metadata composition

The metadata merge projects now live under `src/metadata/MergedWinMD`. Shared
MSBuild references use `$(MergedWinMDProjectRoot)` so project references do not
depend on a root-level `MergedWinMD` folder.

## Repo tools

The Visual Studio helper project that refreshes the mock Windows App SDK package
now lives under `tools/UpdateMockWinAppSDKPackage`, keeping root-level files
limited to repository-wide entry points and configuration.

The standalone debugger extension script now lives under `tools/dbgext`, grouped
with other manually invoked repo tools.

## Specs documentation

Feature and API design specs now live under `docs/specs`. API review specs moved
from `docs/api-specs` to `docs/specs/api` so all checked-in specs share one docs
root while preserving each spec's local image and support-file layout.

## Runtime path preparation

Runtime source remains under `dxaml/xcp` for now. Shared MSBuild entry points
should refer to it through `$(XcpPath)` instead of spelling
`$(XamlSourcePath)\xcp` directly, reducing the number of edits required when the
runtime tree is eventually moved under `src/runtime`. Runtime-local MSBuild
projects and props files follow the same rule for references back into the XCP
tree. Test, phone, and controls MSBuild projects that consume runtime source
should also prefer `$(XcpPath)` over repo-root-relative `dxaml\xcp` paths.
Runtime build-output references should prefer `$(XcpObjPath)` over spelling
`dxaml\xcp` under `$(ArtifactsObjDir)` or `$(XamlBuildOutputRoot)` directly.
Phone project references and include paths should prefer `$(XcpPhonePath)` over
spelling `$(XamlSourcePath)\phone` or repo-root-relative `dxaml\phone` directly.
Graph augmentation projects define the same minimal path properties locally so
their lightweight project graph files can avoid hard-coded runtime-relative
paths without importing the full root build props. Developer initialization
scripts expose the runtime source root as `XcpRoot` so command aliases, restore
scripts, and scripted runtime build entry points can also avoid spelling
`dxaml\xcp` repeatedly.

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
2. Move `dxaml/xcp` to `src/runtime` last, because it has the broadest MSBuild
   and native project surface.
