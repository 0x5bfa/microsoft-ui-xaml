# Source code structure

## Table of Contents

- [/.github](#github)
- [/build, /tools](#build-tools)
- [/controls](#controls)
- [/docs](#docs)
- [/dxaml](#dxaml)
- [/eng](#eng)
- [/external](#external)
- [/generated](#generated)
- [/packaging](#packaging)
- [/scripts](#scripts)
- [/src](#src)
- [/tests](#tests)

## /.github
This folder contains GitHub repository metadata, including workflows, issue and
pull request templates, resource-management policy, Copilot instructions, and
agent skills.

## /build, /tools
These folders contain scripts and other support machinery that you shouldn't 
need to edit for most changes.

In particular: /build/NuSpecs enables .nupkg generation

The mock Windows App SDK package update helper lives under
`/tools/packaging/UpdateMockWinAppSDKPackage`.
The WinUI component package command implementation lives under
`/tools/packaging`.
Standalone debugger extension scripts live under `/tools/debugging/dbgext`.
Build wrapper command implementations live under `/tools/build`, with root
entry points kept for compatibility where needed.
Shared command wrappers live under `/tools/common`.
Developer environment setup helpers live under `/tools/setup`.
Controls build machine maintenance helpers live under `/controls/tools/BuildMachine`.
Controls custom MSBuild task sources, targets, and solution live under `/controls/tools/BuildTasks`.
Controls scaffolding helpers live under `/controls/tools/ControlGeneration`.
Controls release helper scripts live under `/controls/tools/Release`.
Controls resource generation helpers live under `/controls/tools/ResourceGeneration`.
Controls developer shell helpers live under `/controls/tools/Shell`.
Controls shared command wrappers live under `/controls/tools/Common`.
Controls packaging helpers live under `/controls/tools/Packaging`.
Controls source maintenance helpers live under `/controls/tools/SourceMaintenance`.
Controls test app deployment, installation, and dependency helpers live under `/controls/tools/TestAppDeployment`.
Controls test reporting helpers live under `/controls/tools/TestReporting`.
Controls XAML processing and WinUI 2 migration helpers live under `/controls/tools/XamlProcessing`.

## /controls
This folder contains controls solution, IDL, test, and tooling entry points.
The Microsoft.UI.Xaml.Controls.dll implementation source lives under `/src/controls`.
Controls-specific build support lives under `/controls/build`, including
feature-area selection, project import manifests, and shared props/targets.
Controls test-app build helpers live under `/controls/test/build`.

See the [layout refactor notes](building/repo-layout-refactor.md) for more
information about the controls section of the repo.

## /docs
This is where the repo documentation lives, including this document.
Feature and API design specs live under `/docs/specs`, with API review specs
under `/docs/specs/api`.

Note that developer usage documentation can be found separately on docs.microsoft.com.

## /dxaml
This legacy folder is no longer the primary home for WinUI runtime source.

## /eng
All build system and other engineering related files go in this directory.
For more information on the build system, see the [build system design](build-system-design.md)
Ad hoc app build support lives under `/eng/adhoc`.
Binplace build rules live under `/eng/binplace`.
Compiler-related build infrastructure lives under `/eng/compiler`.
WebView2-specific build workaround targets live under `/eng/webview2`.
Shared signing inputs live under `/eng/signing`.
Standalone build transform assets live under `/eng/transforms`.
Build temp-folder setup lives under `/eng/tempfolder`.
Project-based restore helpers live under `/eng/restore`.
Versioning props and dependency details live under `/eng/versioning`.
Repository-wide path definitions live under `/eng/paths`.
Common build configuration and repo-wide build defaults live under `/eng/configuration`.
Build-output consumption helpers live under `/eng/consumebinaries`.
CRT/STL linkage rules live under `/eng/crtstl`.
External binary packaging rules live under `/eng/externalbinaries`.
Final-release build defines live under `/eng/finalrelease`.
Graph build support rules and augmentation helpers live under `/eng/graph`.
Light-up metadata targeting rules live under `/eng/lightup`.
Shared MIDL build rules and helper projects live under `/eng/midl`.
MSBuild cache configuration lives under `/eng/projectcaching`.
Shared test-project build settings live under `/eng/testprojects`.
Windows SDK override configuration lives under `/eng/sdkconfig`.
Package layout build rules live under `/eng/packaging`.
Product metadata item definitions live under `/eng/productmetadata`.
In-repo XAML compiler consumption hooks and helper build projects live under
`/eng/xamlcompiler`.
WinRT class registration build rules live under `/eng/winrtclassregistration`.
WinUIDetails package import rules live under `/eng/winuidetails`.

## /external
This folder contains checked-in third-party dependencies. Header-only
dependencies live under `/external/include`.

## /generated
This folder contains checked-in generated output and generated baselines.
Generated controls dependency-property sources live under `/generated/controls/dependencyproperties`.
Generated package IntelliSense XML lives under `/generated/packaging/intellisense`.
Visual test baselines live under `/generated/tests/visualbaselines`.

## /packaging
This folder contains package construction inputs. NuGet package specs live under
`/packaging/nuspecs`, package build assets under `/packaging/build`, and
IntelliSense drop processing under `/packaging/intellisense`. The local
package test feed lives under `/packaging/package-store`.

## /scripts
This folder contains repository initialization and shared utility scripts.
Initialization helpers live under `/scripts/init`; root entry points such as
`init.cmd`, `init.ps1`, and `initrun.ps1` are kept for compatibility where needed.

## /src
This is where source code for repo-local tools and source components outside the
runtime and controls trees live.

The XAML compiler now lives under `/src/compiler`. That folder contains the
compiler build tasks, executable host, parsing projects, MSBuild targets, and
compiler-specific tools and solutions.

The WinUI controls implementation now lives under `/src/controls`. Controls
solution, IDL, test, and tooling entry points continue to live under `/controls`
and refer to the source tree through `$(MUXControlsSourceRoot)`.

The Microsoft.UI.Xaml.dll runtime implementation now lives under
`/src/runtime/xcp`, with runtime solution entry points and phone-specific source
also under `/src/runtime`.

Metadata composition projects now live under `/src/metadata`. The MergedWinMD
projects are referenced through `$(MergedWinMDProjectRoot)`.

## /tests
This folder contains test assets that have been separated from product source
trees. Compiler test entry points live under `/tests/compiler`; shared test
payload and Helix infrastructure lives under `/tests/infra`.
