# Repository Layout Refactor

This document records the intended direction for folder-structure-only cleanup.
The goal is to make the first path segment answer "what kind of thing is this?"
instead of preserving only historical component names.

## Current direction

Use these ownership buckets for new moves:

| Area | Purpose |
| --- | --- |
| `.github` | GitHub workflows, templates, policies, Copilot instructions, and agent skills. |
| `src/runtime` | Runtime implementation, including the XCP tree under `src/runtime/xcp`. |
| `src/controls` | WinUI controls implementation. |
| `src/compiler` | XAML compiler source, build tasks, compiler targets, and compiler-local tools. |
| `src/metadata` | Metadata composition projects that produce repo-local WinMD inputs. |
| `tests` | Runtime, controls, compiler, sample, and Helix test assets. |
| `eng` | Shared build, packaging, versioning, signing, and pipeline infrastructure. |
| `external/include` | Checked-in third-party header dependencies. |
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
`eng/compiler/XamlCompilerPublic.csproj`. It is build infrastructure rather
than compiler source, and keeping it under `eng` avoids importing the
compiler-local `Directory.Build.props`.

Compiler-local developer tools should live under `tools/compiler` instead of
being nested inside product source or parser implementation folders. The
BindingPath `PathVisualizer`, XAML compiler ETL viewer, compiler performance
collection scripts, and compiler coverage instrumentation helper live there so
`src/compiler` stays focused on compiler source, build tasks, and targets.

## Compiler test entry points

Compiler-specific test entry points and support helpers now live under
`tests/compiler`. `XamlCompilerTests.sln` moved there, while `runtests.cmd`,
`copynewmasters.cmd`, the `FixMasters` helper used by `copynewmasters.cmd`, and
the VcMeta hash validation helper now live under `tests/compiler/tools` instead
of the compiler source tools folder. The compiler source solution references
unit-test projects through `tests/compiler`.
Native compiled-binding coverage for the external tools test project now lives
under `tests/compiler/native/compiledBindings`, with build projects consuming it
through `$(CompilerTestPath)`.

## Shared test infrastructure

Test payload tooling and Helix orchestration now live under `tests/infra`.
`CreateTestPayload.cmd` and `CreateTestPayload.ps1` now live under
`tests/infra/payload/tools`, while the WinUI-specific Helix work-item generation
wrapper now lives beside the shared generator under
`tests/infra/Helix/common/pipeline/tools`. Shared Azure Pipelines helpers live
under `tests/infra/Helix/common/pipeline/tools`. Copied payload runtime commands
live under `tests/infra/payload/commands` and
`tests/infra/Helix/payload/commands`. The Helix test-runner payload assets are
grouped under `tests/infra/Helix/payload/test` and are still copied to
the payload root when constructing `TestPayload`. GitHub agent skill metadata
now references these paths directly instead of the removed root wrappers and
legacy `dxaml/test` layout.

## Runtime test tools

Runtime-specific test tools should move out of `dxaml/test/tools` as their
references are isolated. `XmlValidation`, `MockDCompInjector`, `detours`, and
the test `codegen` helper now live under `tests/runtime/tools`. The `codegen`
command wrapper is co-located with that helper. The runtime solution keeps
project references to the project-based tools, and `DetoursPath` centralizes
the remaining detours import consumers. The external tools custom types support
project now lives under `tests/runtime/tools/customTypes`; projects consume it
through `$(RuntimeToolsCustomTypesPath)` and generated includes through
`$(RuntimeToolsCustomTypesObjPath)`.

## Runtime test packages

Runtime test AppX manifest inputs now live under `tests/runtime/packages/appx`.
They are test packaging assets rather than runtime source, and the runtime
solution references the package project from that test-owned location. AppX
package maintenance helpers live under `tests/runtime/packages/appx/tools`.
The temporary WebView2 Runtime installer staging path now lives under
`tests/runtime/packages/edge` because it feeds the test-only
`Microsoft.UI.DCPP.Dependencies.Edge` package.

## Runtime AppAnalysis test support

AppAnalysis test support projects now live under `tests/runtime/appanalysis`.
`$(RuntimeTestPath)` and `$(AppAnalysisTestPath)` provide shared references for
runtime projects and AppAnalysis unit tests that consume those support projects.
The AppAnalysis engine and rule unit-test projects now live under
`tests/runtime/appanalysis/unittests`, alongside their AppAnalysis-specific
test props and precompiled-header project. The external tools AppAnalysis
integration tests now live under `tests/runtime/appanalysis/integration`, with
the external tools test DLL consuming them through `$(AppAnalysisTestPath)`.

## Runtime XamlDiagnostics test support

The external tools XamlDiagnostics integration tests now live under
`tests/runtime/xamldiagnostics/integration`. `$(XamlDiagnosticsTestPath)`
provides the shared test root, while XamlDiagnostics TAP binaries remain under
`tools/runtime/xamldiagnostics/tap` and continue flowing through
`$(XamlDiagTapPath)`.

## Runtime ETW test support

The external tools ETW integration tests now live under
`tests/runtime/etw/integration`. `$(RuntimeEtwTestPath)` provides the shared
test root for input-event and layout-causality ETW coverage consumed by the
external tools test DLL.

## Runtime XamlBinding test support

The external tools XamlBindingHelper integration tests now live under
`tests/runtime/xamlbinding/integration`. `$(XamlBindingTestPath)` provides the
shared test root, while the XamlBindingHelper test XAML payload remains with
the runtime resource payloads under `tests/runtime/resources`.

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
living under the legacy runtime resource tree.

Runtime test infrastructure now lives under `tests/runtime/infra`; new and moved
consumers should use `$(RuntimeInfraTestPath)` and
`$(RuntimeInfraTestObjPath)`. The legacy infra wrapper has been removed now that
the runtime infra projects have moved.

Runtime-specific infrastructure hosts live under `tests/runtime/infra`. The
.NET Core TAEF host moved first because it
only needs the runtime test build defaults and solution reference update. The
Invoker helper lives there too, with explicit imports back to the legacy runtime
build props and targets while `src/runtime/xcp` remains in place. The MockDComp copy
shim also lives there because it only binplaces the WinUIDetails MockDComp DLL
for runtime tests. The RPC contract now lives there as the first shared native
runtime infra dependency, with source and generated-output paths exposed through
`$(RuntimeInfraTestPath)` and `$(RuntimeInfraTestObjPath)` for remaining legacy
infra consumers. Shared native test path aliases are available from the root
folder path props so moved runtime infra projects can still consume native test
headers. Shared native test headers now live under `tests/runtime/native/inc`
and are referenced through `$(NativeIncPath)`. The native logging helper moved
with the contract, so client infra can include logging headers from the runtime
infra source path while the client DLL references the moved logging project
directly. The native TAEF host app also lives under runtime infra, while
continuing to package the legacy private infrastructure client from its current
output location. The managed TAEF host app lives next to it and uses shared root
path properties for runtime and private infrastructure project references. The
test dependency binplace project also lives there because it prepares runtime
test dependency payloads rather than legacy runtime source. Shared native
runtime infra headers, Win32 hosting infrastructure, and the private
infrastructure client/server live there too, with native test consumers
referencing them through `$(RuntimeInfraTestPath)` and generated hosting outputs
through
`$(PrivateInfrastructureWin32HostingObjPath)`.

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
`tests/controls/testinfra` next to `MUXTestInfra` instead of under `Samples`, so
the sample-app tree stays focused on sample applications. Testinfra package
creation helpers live under each testinfra package's `tools` folder, and the
WinUI Gallery test-data generator lives under `tests/controls/tools`.

## Sample test automation

Sample test orchestration tools now live under `tests/samples/tools`. The
test payload still publishes them to the payload root, but their source location
now matches their role as test assets rather than sample applications.

## Initialization scripts

.NET SDK, runtime download, MSBuild install, and test certificate generation
helpers now live under `tools/setup/init`. The checked-in post-init restore step
lives there too, while optional local init hooks are resolved from
`tools/setup/custom`. Command prompt and PowerShell alias definitions are co-located there as
initialization shell helpers. They are part of repository initialization rather
than package construction, leaving the `build` folder focused on packaging
inputs and build-time transforms. The command prompt init, PowerShell init, and
initialized-command runner entry points now live under
`tools/setup/init/commands`; the root-level compatibility wrappers were removed
so repo-local callers use the implementation paths directly.

## Packaging inputs

NuGet package specs and package NOTICE content now live under
`packaging/nuspecs`, alongside the rest of the package build inputs. The
top-level package command still invokes the same helper script, but its source
location now reflects that it packs WinUI packaging output. The Edge runtime
dependency nuspec used by WebView2 test package updates also lives there.
Package build targets now live under `packaging/build`, including the target
that keeps the project-capability version in sync with `WinUIVersion`.
Static package manifest inputs live under `packaging/manifests`, keeping
package metadata separate from the project file and package build targets.
Package license inputs live under `packaging/licenses`, while the packaging
project still emits the same `license.txt` package payload name.

## Build transforms

The fusion-manifest transform used by ad hoc app registration now lives under
`eng/transforms`. This removes the last checked-in helper from the historical
`build` folder and keeps standalone transform assets separate from MSBuild
targets.

## XAML build settings

Shared XAML MSBuild settings now live under `eng/buildsettings`. These props
and targets are build infrastructure rather than runtime source, and consumers
resolve them through `$(XamlBuildSettingsPath)` instead of reaching into the
legacy `dxaml/msbuild` tree.

## XAML build rules

Shared XAML MSBuild entry points now live under `eng/xamlbuild`. These files
define common runtime build behavior rather than product source, and consumers
that import after common folder props can resolve them through
`$(XamlBuildRulesPath)`. Projects that import these rules before common props
use `$(MSBuildThisFileDirectory)` relative paths instead, while
`$(XamlSourcePath)` now points at the runtime source root under `src/runtime`.

## Runtime phone source

Phone-specific runtime source now lives under `src/runtime/phone`. It was a
small runtime source slice that already had a centralized `$(XcpPhonePath)`,
making it a safe first runtime-source move before relocating the much larger
XCP tree. The phone projects keep their legacy `dxaml\phone` object layout so
downstream WinMD and include consumers continue to use the existing build-output
paths.

## Runtime solution entry point

The main runtime solution now lives at `src/runtime/Microsoft.UI.Xaml.sln`.
This keeps the runtime build entry point with the runtime-owned source slices
that have already moved under `src/runtime`, with project references now
pointing at the relocated `src/runtime/xcp` tree.

## Package restore inputs

Repository-wide NuGet `packages.config` files now live under `eng/packages`.
They feed initialization and shared version extraction, so grouping them under
`eng` keeps dependency restore inputs with the rest of the build infrastructure.
`Packages.props` remains at the repository root because CentralPackageVersions
projects discover it by walking parent directories.
The Maestro restore helper project lives under `eng/restore`, keeping
project-based restore orchestration with other initialization restore inputs.

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
`packaging/intellisense/drop`.

## Visual test baselines

Checked-in visual test baseline assets now live under
`generated/tests/visualbaselines`. The resource project that packages them now
lives under `tests/runtime/resources/masters` while continuing to expose
`resources\masters` at runtime. The legacy command helper that can regenerate a
masters RC file now lives under `tests/runtime/resources/tools` so generated
resource payload and handwritten maintenance tooling are separated.

Native isolated-test support now lives under `tests/runtime/native/isolated`.
Projects should use `$(NativeIsolatedTestPath)` instead of spelling out the
legacy runtime-source test path.

Native external-test infrastructure is moving under
`tests/runtime/native/external` in small pieces. The shared infrastructure
compile-only project moved first, with consumers using
`$(RuntimeNativeExternalTestPath)` for source and
`$(RuntimeNativeExternalTestObjPath)` for generated object dependencies. Shared
external-test headers live there too, so consumers no longer need to include
headers from the legacy source tree. The external precompiled-header project
also lives there and is referenced through `$(RuntimeNativeExternalTestPath)`.
The activation external test DLL moved next, keeping its shared test props in
the legacy external test root until the remaining external tests follow.
The adaptability external test DLL and its custom types support project also
moved there, with custom type compilation still imported from the legacy
external test root while that shared target remains in place.
The convergence external test DLL moved there as another small self-contained
runtime native external test project.
The external infrastructure integration test DLL moved there too, keeping its
sources with the other runtime native external tests.
The quality external test DLL moved there as another self-contained runtime
native external test project.
The Win32 external test DLL moved there too, while continuing to import the
shared custom type compilation target from the legacy external test root.
The sample external test DLL and its custom types support project also moved
there; it is not solution-referenced today, but it follows the same runtime
native external test layout.
The enterprise external test DLL moved there next, and remaining external tests
that consume its shared helper headers now reference them through
`$(RuntimeNativeExternalTestPath)`.
The Automation external test DLL moved there too; shared automation client
headers are now exposed from the runtime native external test root.
The tools external test DLL moved there next, while its custom types support
project now lives with the runtime test tools and no longer needs a tools-local
`Directory.Build.props` shim.
The framework external test DLL moved there next, with layout design-note test
references updated to point at the new runtime native external test location.
The controls external test DLL and its custom types support project moved there
next; remaining native external consumers now include controls helper headers
through `$(RuntimeNativeExternalTestPath)`.
The foundation external test DLL and its custom types support project moved
there next; remaining native external consumers now include foundation helper
headers through `$(RuntimeNativeExternalTestPath)`.
The shared native external test props and custom-type targets moved there after
the external test DLLs, so runtime external tests now import shared MSBuild
state from `$(RuntimeNativeExternalTestPath)` instead of the legacy `dxaml/test`
tree.

The shared runtime test C++ defaults now live at `tests/runtime/common.props`.
Runtime test projects should import it through `$(RuntimeTestPath)\common.props`
instead of reaching back into the legacy `dxaml/test` tree.
The remaining shared runtime test build defaults now live in
`tests/runtime/RuntimeTest.Directory.Build.props` for explicit importers; it is
not named `Directory.Build.props` at the runtime root so it does not change
MSBuild's automatic parent-directory import behavior for runtime test projects.
Legacy `$(TestPath)` now aliases `$(RuntimeTestPath)`, and remaining isolated
unit-test include paths should use runtime test properties such as
`$(RuntimeInfraTestPath)` and `$(RuntimeDCompTestPath)` instead of spelling
`dxaml/test` paths directly.
The WinUri isolated test project is now under
`tests/runtime/native/isolated/framework/winuri`, starting the move of
component-local isolated test projects out of the runtime source tree.
The DependencyLocator isolated test moved next under
`tests/runtime/native/isolated/framework/dependencyLocator` using the same
runtime-test-owned layout.
The CValue isolated test also moved under
`tests/runtime/native/isolated/framework/CValue`, continuing the framework
isolated test migration out of `src/runtime/xcp`.
The RuntimeEnabledFeatureDetector isolated test moved under
`tests/runtime/native/isolated/framework/runtimeEnabledFeatures` with the same
runtime test structure.
The Deferral isolated test moved under
`tests/runtime/native/isolated/framework/deferral`, with its product source
compile item referenced through `$(XcpPath)` instead of a project-relative path.
The SimpleProperties isolated test moved under
`tests/runtime/native/isolated/framework/simple`, keeping generated test-local
headers with the moved test project.
The ValueBoxer isolated test moved under
`tests/runtime/native/isolated/framework/valueboxer`, keeping its test stubs and
property wrappers with the runtime test project.
The Math isolated test moved under
`tests/runtime/native/isolated/foundation/math`, starting the foundation
isolated test migration with a small self-contained project.
The Threading isolated test moved under
`tests/runtime/native/isolated/foundation/threading`, keeping the foundation
isolated test projects grouped with runtime tests.
The XString isolated test moved under
`tests/runtime/native/isolated/foundation/xstring`, continuing to pull small
foundation test projects out of the runtime source tree.
The Colors isolated test moved under
`tests/runtime/native/isolated/foundation/colors`, keeping another compact
foundation test project with the runtime test tree.
The COM isolated test moved under
`tests/runtime/native/isolated/foundation/com`, following the same compact
foundation test project layout.
The OfferableHeap isolated test moved under
`tests/runtime/native/isolated/foundation/offerableheap`, keeping the
foundation isolated test migration moving through small self-contained projects.
The Brushes isolated test moved under
`tests/runtime/native/isolated/foundation/brushes`, retaining its DComp test
property usage while moving the project out of the runtime source tree.
The ThemeAnimationsHelper isolated test moved under
`tests/runtime/native/isolated/foundation/themeanimationshelper`, continuing the
foundation isolated test migration with another self-contained project.
The Text isolated test moved under
`tests/runtime/native/isolated/foundation/text`, keeping the compact text test
project with the runtime test tree.
The Flyweight isolated test moved under
`tests/runtime/native/isolated/foundation/flyweight`, keeping another compact
foundation-style isolated test project with runtime tests.
The Associative isolated test moved under
`tests/runtime/native/isolated/foundation/associative`, continuing the migration
of compact runtime component tests into the runtime test tree.
The Base isolated test moved under
`tests/runtime/native/isolated/foundation/base`, grouping its low-level
collection and storage tests with the other foundation runtime tests.
The Animation isolated test moved under
`tests/runtime/native/isolated/foundation/animation`, retaining its DComp test
property usage while moving the project out of the runtime source tree.
The Transforms isolated test moved under
`tests/runtime/native/isolated/foundation/transforms`, and the Elements
isolated test now references it through `$(NativeIsolatedTestPath)`.
The Imaging isolated test moved under
`tests/runtime/native/isolated/foundation/imaging`, keeping its MockDComp and
binplace configuration with the moved test project.
The Elements isolated test moved under
`tests/runtime/native/isolated/foundation/elements`, with documentation links to
the UIElement tests updated to the runtime test tree.
The DependencyObject isolated test moved under
`tests/runtime/native/isolated/framework/dependencyObject`, continuing the
framework isolated test migration out of the runtime source tree.
The Metadata isolated test moved under
`tests/runtime/native/isolated/framework/metadata`, while the shared metadata
mocks remain in the runtime source tree until their consumers are migrated.
The Input isolated test moved under
`tests/runtime/native/isolated/core/input`, starting a core isolated test group
for component tests whose project identity is `Microsoft.UI.Xaml.Tests.Isolated.Core.*`.
The Gestures isolated test moved under
`tests/runtime/native/isolated/core/gestures`, continuing the core isolated test
group alongside Input.
The FocusSelection isolated test moved under
`tests/runtime/native/isolated/xaml/focus/focusSelection`, starting a XAML focus
isolated test group under runtime tests.
The RelativePanel isolated test moved under
`tests/runtime/native/isolated/controls/relativePanel`, starting a controls
isolated test group under runtime tests.
The LiveReorderHelper isolated test moved under
`tests/runtime/native/isolated/controls/liveReorderHelper`, keeping
control-adjacent isolated helper tests with the controls runtime test group.
The ItemIndexRangeHelper isolated test moved under
`tests/runtime/native/isolated/enterprise/itemIndexRangeHelper`, starting an
enterprise isolated test group under runtime tests.
The VisualStatesHelper isolated test moved under
`tests/runtime/native/isolated/enterprise/visualStatesHelper`, continuing the
enterprise isolated test group under runtime tests.
The Qualifiers isolated test moved under
`tests/runtime/native/isolated/adaptability/qualifiers`, starting an
adaptability isolated test group under runtime tests.
The XYFocus isolated test moved under
`tests/runtime/native/isolated/xaml/focus/xyFocus`, continuing the XAML focus
isolated test group under runtime tests.
The Theming isolated test moved under
`tests/runtime/native/isolated/controls/theming`, continuing the controls
isolated test group under runtime tests.
The Pivot isolated test moved under
`tests/runtime/native/isolated/controls/pivot`, continuing the controls
isolated test group under runtime tests.
The Moco isolated test moved under
`tests/runtime/native/isolated/controls/moco`, continuing the controls isolated
test group under runtime tests.
The Graphics isolated test moved under
`tests/runtime/native/isolated/foundation/graphics`, keeping graphics
infrastructure isolated tests with the foundation runtime test group.
The XamlDiagnostics isolated test moved under
`tests/runtime/native/isolated/xaml/diagnostics`, starting a XAML diagnostics
isolated test group under runtime tests.
The DXamlCore TIP isolated test moved under
`tests/runtime/native/isolated/xaml/dxamlCore`, keeping DXamlCore test coverage
with the other XAML isolated runtime tests.
The Parser isolated test moved under
`tests/runtime/native/isolated/framework/parser`, continuing the framework
isolated test group under runtime tests.
The Lifetime isolated test moved under
`tests/runtime/native/isolated/foundation/lifetime`, keeping runtime lifetime
coverage with the foundation isolated test group.
The Legacy isolated test moved under
`tests/runtime/native/isolated/foundation/legacy`, keeping low-level legacy
helper coverage with the foundation isolated test group.
The AccessKeys isolated tests moved under
`tests/runtime/native/isolated/xaml/accessKeys`, with shared AccessKeys test
mocks in `tests/runtime/native/isolated/xaml/accessKeys/shared`.
The Collection isolated test moved under
`tests/runtime/native/isolated/foundation/collection`, keeping collection
coverage with the foundation isolated test group.
Shared isolated test stubs, external mocks, and support headers moved under
`tests/runtime/native/isolated/shared`, so component tests can reference shared
test infrastructure through `$(NativeIsolatedTestPath)`.
Shared framework metadata mocks moved under
`tests/runtime/native/isolated/shared/mocks/metadata`, so parser, metadata,
ValueBoxer, and focus isolated tests no longer reference metadata test mocks
from the component source tree.
The remaining KeyDownUp source-only unit test files moved under
`tests/runtime/native/isolated/controls/keyDownUp`, keeping those test sources
with the controls isolated test tree without changing project participation.

## Controls source

The WinUI controls implementation now lives under `src/controls`, including
the controls IDL inputs under `src/controls/idl`. The `controls` tree remains
the home for controls solution files, tests, and authoring tools. Shared MSBuild
entry points use `$(MUXControlsSourceRoot)` and `$(MUXControlsIdlRoot)` so those
support projects can reference controls source without reintroducing the old
`controls/dev` or `controls/idl` path segments.

Controls-specific build support files are moving under `controls/build` in
small pieces. The shared MIDL props and targets live there, with IDL and
controls DLL projects importing them through `$(MUXCProjectRoot)build`. Native
C++/WinRT, CRT, SDK-version, package-version, shared project-configuration
settings, feature-area selection, inner-loop feature overrides, and shared
controls project imports live there too.

## Metadata composition

The metadata merge projects now live under `src/metadata/MergedWinMD`. Shared
MSBuild references use `$(MergedWinMDProjectRoot)` so project references do not
depend on a root-level `MergedWinMD` folder.

## Repo tools

GitHub-facing repository metadata lives under `.github`. Copilot instructions
and repo-local agent skills moved there from `src/.github` so `src` stays
focused on source components and GitHub can discover the metadata from its
standard location.

Checked-in third-party headers now live under `external/include`, replacing the
abbreviated `external/inc` path while keeping runtime include path consumers
centralized in shared MSBuild props.

WebView2-specific build workaround targets now live under `eng/webview2`, so
general `eng` props and targets are less mixed with package-specific temporary
compatibility shims.

Ad hoc app build props, targets, and registration support now live under
`eng/adhoc`, keeping those opt-in test/sample app hooks together.

Shared signing inputs now live under `eng/signing`, starting with the strong
name key used by compiler and projection assemblies.

Shared MIDL props, targets, and generated-header/IDL helper projects now live
under `eng/midl`, keeping WinMD build composition rules together.

MSBuild cache props and targets now live under `eng/projectcaching`, grouping
the optional cache package configuration and target import in one place.

Shared test-project props and targets now live under `eng/testprojects`,
keeping opt-in test project build behavior out of the `eng` root.

Windows SDK override props and targets now live under `eng/sdkconfig`, keeping
early SDK package import configuration together.

Repository folder path props now live under `eng/paths`, keeping central path
definitions out of the `eng` root.

Common build configuration props and ARM64EC target overrides now live under
`eng/configuration`, grouping repo-wide defaults and platform/configuration
defaults together.

Build-output consumption props and targets now live under `eng/consumebinaries`,
keeping the ad hoc/test app hooks for consuming built WinUI binaries together.

Package layout props and targets now live under `eng/packaging`, leaving the
top-level `packaging` tree focused on package construction inputs.

In-repo XAML compiler consumption props, targets, and helper restore/build
projects now live under `eng/xamlcompiler`, separate from the broader runtime
XAML build rules in `eng/xamlbuild`. The `BuildGenXbfForMSBuild` helper moved
there with the compiler-consumption infrastructure that invokes GenXbf during
MSBuild-based XAML compilation.

WinRT class registration targets now live under `eng/winrtclassregistration`,
keeping metadata-driven package registration generation in its own build bucket.

External binary selection targets now live under `eng/externalbinaries`, keeping
package payload selection rules separate from root-level build entry points.

Binplace targets now live under `eng/binplace`, grouping output-copy rules with
the rest of the build rule buckets instead of the `eng` root.

CRT/STL linkage targets now live under `eng/crtstl`, keeping native runtime
linkage policy separate from root-level build imports.

Light-up metadata targeting targets now live under `eng/lightup`, grouping the
downlevel contract metadata policy away from root-level build imports.

Product metadata item definitions now live under `eng/productmetadata`, keeping
the product WinMD and binary item lists in a named build-data bucket.

Build temp-folder setup now lives under `eng/tempfolder`, keeping the TEMP/TMP
environment hook with other named build rule buckets.

WinUIDetails package import targets now live under `eng/winuidetails`, keeping
that external package wrapper separate from root-level build imports.

Graph build support targets and GraphAugmentation helper projects now live
under `eng/graph`, grouping graph-build scheduling support in one bucket.

Final-release build defines now live under `eng/finalrelease`, keeping the
`MUXFinalRelease` prerelease constants in a named build settings bucket.

Versioning props and dependency details now live under `eng/versioning`, keeping
package version extraction and WinUI file-version defines together.

The Visual Studio helper project that refreshes the mock Windows App SDK package
now lives under `tools/packaging/UpdateMockWinAppSDKPackage`, keeping
root-level files limited to repository-wide entry points and configuration.

The local NuGet package test feed now lives under `packaging/package-store`.
Package construction scripts, NuGet.config, and cleanup helpers point there
instead of keeping a single-purpose `PackageStore` folder at the repo root.
The WinUI component package command implementation now lives under
`tools/packaging/commands` with the package construction PowerShell helper. The
repo root compatibility wrapper was removed; repo-local callers should use
`tools/packaging/commands/pack.component.cmd` directly.

The standalone debugger extension script now lives under
`tools/debugging/dbgext`, grouped with other manually invoked repo tools.

Clang-oriented developer helpers now live under `tools/clang`, with
`tools/setup/init/commands/init.cmd` adding that folder to PATH so the short command names
remain available in initialized shells.

Build wrapper commands now live under `tools/build/commands`, with
`tools/setup/init/commands/init.cmd` adding that folder to PATH so commands such as `msb`,
`bz`, `bcz`, and `clean` remain available in initialized shells. The main repo build command implementation
also lives there now. The root-level `Build.cmd` compatibility wrapper was
removed; repo-local callers should use `tools/build/commands/Build.cmd` directly.

Shared command wrappers used by multiple repo tools now live under
`tools/common`, keeping the `tools` root focused on tool categories.

Developer environment setup helpers now live under `tools/setup`. The
one-time bootstrap entry point and its PowerShell implementation live under
`tools/setup/bootstrap`, while init command entry points live under
`tools/setup/init/commands` and the Visual Studio developer command prompt
setup implementation lives under `tools/setup/shell`. There are no shallow
setup compatibility wrappers; repo-local callers and external jobs should call
the command paths directly.

Controls shared build support files live under `controls/build`, while the
controls build command implementation now lives under
`tools/controls/Build/commands`.
The root-level `controls/Build.cmd` wrapper was removed and solution items now
point at `tools/controls/Build/commands/Build.cmd`. Root-level controls props files that
are discovered by MSBuild remain as thin wrappers over their implementations in
`controls/build`. The controls `Directory.Build.props` and
`Directory.Build.targets` implementations also live in `controls/build`, while
the root files remain as MSBuild auto-discovery wrappers.

Controls build machine maintenance helpers now live under
`tools/controls/BuildMachine`, keeping the queue/build-machine scripts grouped
with their shared ADAL-backed helper module.

Controls new-control scaffolding helpers now live under
`tools/controls/ControlGeneration`, with reusable `NEWCONTROL` templates under
that folder's `Templates` directory.

Controls release helper scripts now live under `tools/controls/Release`,
keeping the interactive release workflow next to its ADAL authentication helper.

Controls resource generation helpers now live under
`tools/controls/ResourceGeneration`, including system DLL resource generation,
visual verification update, final-release theme resource trimming scripts, and
the baseline resources generator app.

Controls developer shell helpers now live under `tools/controls/Shell`,
including the developer command prompt implementation, command aliases, and the
PowerShell profile loaded by `ps.bat`. The root-level `controls/DevCmd.cmd`
wrapper was removed; controls developers should use
`tools/controls/Shell/DevCmd.cmd` directly.

Controls shared command wrappers now live under `tools/controls/Common`,
including the NuGet and PowerShell wrappers used by controls tooling scripts.

Controls custom MSBuild task sources and their test harness now live under
`tools/controls/BuildTasks`, with the task NuGet packaging scripts kept under
the moved `CustomTasks/NuSpecs` tree and the dedicated build-task solution
co-located with those tools. The cleanup project that invokes the custom
`KillMSBuild` task also lives in this folder with its runtime config. The
shared inline MSBuild task target file is grouped here too.

Controls packaging helpers now live under `tools/controls/Packaging`,
including the framework package AppX creation wrapper used after controls
builds, package-generation restore config, local signing stub, and build-drop
publishing helper.

Controls source maintenance helpers now live under
`tools/controls/SourceMaintenance`, including namespace update, vcxitems page
reference cleanup, and text template processing scripts.

Controls packaged test app deployment helpers now live under
`tools/controls/TestAppDeployment`. Build integration still copies
`CreateAppxDirectory.msbuildproj` and `InstallAppFromLayout.ps1` into the test
app output directory with their original filenames, preserving runtime install
script discovery. Test app dependency extraction and AppX dependency XML
generation scripts also live in this folder. The desktop test-app install
wrapper lives there too, with its package payload references resolving through
the `tools/controls/TestAppDeployment` payload helpers.

Controls test reporting helpers now live under `tools/controls/TestReporting`,
grouping the unreliable-test report creation and console output scripts away
from the `tools/controls` root.

Controls XAML processing and WinUI 2 migration helpers now live under
`tools/controls/XamlProcessing`, including the generic XAML merge script used
by the controls build.

Controls test-app build helpers now live under `tests/controls/build`, keeping
the controls test root focused on test entry points and automatically discovered
MSBuild defaults. `IXMPTestApp`, `TabViewTearOutApp`, `TestAppCX`, and
`MUXControlsTestApp` now live under `tests/controls/apps`.
Shared controls test-app utility code now lives under
`tests/controls/shared/TestAppUtils`, keeping shared test support separate from
concrete app and test-infrastructure entry points.
Controls test UI shared projects are moving under `tests/controls/testui`.
`ItemContainer_TestUI` and `RadialGradientBrush_TestUI` moved first because
they are small self-contained shared projects imported by MUXControlsTestApp and
the controls solutions. The next batch moved the small AutoSuggestBox,
ColorPicker, ComboBox, DropDownButton, Expander, ImageIcon, InfoBadge, and
PersonPicture TestUI projects into the same test-owned tree. RatingControl,
SplitButton, SplitView, TwoPaneView, RadioMenuFlyoutItem,
MonochromaticOverlayPresenter, MapControl, and SystemBackdropElement followed
as the next small controls TestUI batch. Additional top-level TestUI shared
projects for AnimatedVisualPlayer, InfoBar, NumberBox, PagerControl, TitleBar,
Breadcrumb, PipsPager, ProgressBar, RadioButtons, SelectorBar, WebView2,
AnimatedIcon, AnnotatedScrollBar, CommandBarFlyout, ProgressRing, and
TeachingTip now live there too. Interaction TestUI projects moved under
`tests/controls/testui/Interactions`, PullToRefresh TestUI projects moved under
`tests/controls/testui/PullToRefresh`, and the historical MenuBar and
SwipeControl `_TestUI` folders were renamed into direct testui feature folders.
ParallaxView, ScrollView, TabView, and TreeView TestUI shared projects now live
under direct `tests/controls/testui` feature folders as well.
Materials TestUI shared projects moved under `tests/controls/testui/Materials`
so Acrylic and Reveal test UI stays grouped by its feature family outside
controls source.
ScrollPresenter TestUI now lives under `tests/controls/testui/ScrollPresenter`,
continuing the move of control-specific test pages out of product source.
NavigationView TestUI followed under `tests/controls/testui/NavigationView`,
including its Common, CustomResources, Footer, Hierarchical, Regression, and
TopMode test page groups.
CommonStyles TestUI now lives under `tests/controls/testui/CommonStyles`,
keeping shared style and common control test pages with the rest of controls
test UI.

Runtime developer tools should move out of `src/runtime/xcp/tools` when they are not
product source or test assets. `DumpXbf` now lives under `tools/runtime/DumpXbf`
as the first small runtime tool move. The XBF parser/viewer tools moved under
`tools/runtime/XbfParser`, with initialization restore and generated
WidgetSpinner metadata paths updated to the new tool-owned location. The
standalone `SplitGenericXaml` project also moved under
`tools/runtime/SplitGenericXaml`; runtime theme generation still builds its
local copy from `src/runtime/xcp/dxaml/themes/autogen`. `GenXbfDLL` moved under
`tools/runtime/GenXbfDLL` as a build-integrated runtime tool, with MSBuild
project references using `$(RuntimeToolsPath)`. The runtime code generation
toolchain moved under `tools/runtime/XCPTypesAutoGen`, including the
checked-in stable XBF index inputs and the `runcodegen.cmd` wrapper. The
XamlDiagnostics TAP test DLL moved under `tools/runtime/xamldiagnostics/tap`,
with external tool tests consuming it through `$(XamlDiagTapPath)`. The
AppAnalysis runtime diagnostics toolchain moved under `tools/runtime/AppAnalysis`,
with shared references flowing through `$(AppAnalysisPath)` and
`$(AppAnalysisObjPath)`. The Unicode classification data generator script and
its binary input now live under `tools/runtime/TextClassification`, while the
checked-in generated `UcdData.cpp` lives under
`generated/runtime/text/Classification` and is consumed through
`$(RuntimeTextClassificationGeneratedPath)`.
Legacy `dxaml/tools/xamldiagnostics` references have been retired. Product
XamlDiagnostics source is addressed through `$(XamlDiagnosticsComponentPath)`,
while the manually invoked/test TAP project remains under
`tools/runtime/xamldiagnostics/tap`.

## C#/WinRT projection source

The WinUI C#/WinRT projection source lives under `src/projection`. Public
projection type-forwarder source files now live under
`src/projection/TypeForwarders`, keeping the projection root focused on project
entry points and shared build configuration.

## Specs documentation

Feature and API design specs now live under `docs/specs`. API review specs moved
from `docs/api-specs` to `docs/specs/api` so all checked-in specs share one docs
root while preserving each spec's local image and support-file layout. API
process docs remain at the `docs/specs/api` root, while feature-specific API
specs move into named subfolders such as `PipsPager`, `XamlOptionalChanges`,
`XamlRoot`, `DesktopWindowXamlSource`, and `ScrollPresenter`. Stale
TitleBar and InfoBadge spec duplicates under `docs/design-notes` have been
retired now that `docs/specs/TitleBar` and `docs/specs/InfoBadge` are the
spec-owned locations. Asset-free standalone specs such as DispatcherShutdownMode,
TreeView SelectionChanged, WindowsXamlManager shutdown improvements, WebView2
custom environment, symbol enum, and TabTearOut API now live directly under
`docs/specs`. The SelectorBar spec set moved as a feature folder under
`docs/specs/SelectorBar` with its local images. The MapControl spec and its
scenario image moved under `docs/specs/MapControl`. The CustomTitleBar spec
and its spec-specific image moved under `docs/specs/CustomTitleBar`, while the
conceptual design note remains under `docs/design-notes`. The
ItemCollectionTransitionProvider and TabTearOut specs now live under matching
feature folders in `docs/specs`, with their local images. The LayoutCycle
DebugSettings and AnnotatedScrollBar specs moved there too, with design-note
overviews linking to their spec-owned locations. The ItemContainer functional
spec moved under `docs/specs/ItemContainer` with its local images.

## Developer documentation

Developer-facing markdown now lives under purpose-named folders below `docs`.
Build/setup workflows live under `docs/building`, test and validation workflows
under `docs/testing`, debugging and telemetry notes under `docs/debugging`,
release and Windows App SDK integration notes under `docs/publishing`, and
contributor-facing guidance under `docs/external`. Design-oriented architecture
notes live under `docs/design-notes`, grouped by feature or runtime area.
WebView2 dependency update and version-history docs now live under
`docs/publishing`, keeping dependency publishing workflows out of the controls
implementation source tree.
The WebView2 build/run guide now lives under `docs/building`, keeping sample
workflow docs with the other build documentation.
The WebView2 UIA and accessibility note now lives under
`docs/design-notes/input`, next to the input architecture note that references
it.

The `docs` root is intentionally limited to the developer documentation index
and repository structure overview. New docs should pick an existing category
folder before adding another root-level markdown file.

## Runtime path preparation

Runtime source now lives under `src/runtime/xcp`. Shared MSBuild entry points
should refer to it through `$(XcpPath)` instead of spelling the runtime source
root directly. Runtime-local MSBuild projects and props files follow the same
rule for references back into the XCP tree. Test, phone, and controls MSBuild
projects that consume runtime source should also prefer `$(XcpPath)` over
repo-root-relative `src\runtime\xcp` paths.
Runtime build-output references should prefer `$(XcpObjPath)` over spelling
`dxaml\xcp` under `$(ArtifactsObjDir)` or `$(XamlBuildOutputRoot)` directly.
Phone project references and include paths should use `$(XcpPhonePath)` instead
of spelling either the current `src\runtime\phone` location or legacy
`dxaml\phone` paths directly.
Graph augmentation projects define the same minimal path properties locally so
their lightweight project graph files can avoid hard-coded runtime-relative
paths without importing the full root build props. Developer initialization
scripts expose the runtime source root as `XcpRoot` so command aliases, restore
scripts, and scripted runtime build entry points can also avoid spelling
`src\runtime\xcp` repeatedly. Runtime tool wrappers should consume `XcpRoot`
when they need the runtime source root.

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

1. Continue moving compiler regression project assets into `tests/compiler` as
   they become present in the checkout and their generation/update workflows are
   verified.
2. Continue retiring legacy `src/runtime/xcp` references from documentation and
   comments as nearby files are touched.
