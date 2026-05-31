# Source code structure

## Table of Contents

- [/.github](#github)
- [/tools](#tools)
- [/docs](#docs)
- [/eng](#eng)
- [Checked-In Dependencies And Generated Assets](#checked-in-dependencies-and-generated-assets)
- [/src](#src)
- [/tests](#tests)

## /.github
This folder contains GitHub repository metadata, including workflows, issue and
pull request templates, resource-management policy, Copilot instructions, and
agent skills.

## /tools
This folder contains manually invoked repo tools and support machinery that you
shouldn't need to edit for most changes.

The mock Windows App SDK package update helper lives under
`/tools/packaging/UpdateMockWinAppSDKPackage`.
The WinUI component package command implementation lives under
`/tools/packaging/scripts`.
Package IntelliSense generation helpers live under
`/tools/packaging/intellisense`, while docs-team XML drop inputs live under
`/eng/packaging/intellisense`.
Compiler developer tools, performance collection scripts, and coverage helpers
live under `/tools/compiler`.
Runtime developer tools and source-generation helpers live under `/tools/runtime`.
Standalone debugger extension scripts live under `/tools/debugging/dbgext`.
Build wrapper command implementations live under `/tools/build/scripts`.
Shared command wrappers live under `/tools/common/scripts`.
Developer environment setup helpers live under `/tools/setup`, with command
entry points under `/tools/setup/init/scripts`, one-time bootstrap under
`/tools/setup/bootstrap/scripts`, and the Visual Studio developer shell under
`/tools/setup/shell/scripts`.
Controls build machine maintenance helpers live under `/tools/controls/BuildMachine/scripts`.
Controls custom MSBuild task sources, package inputs, targets, and solution live
under `/tools/controls/BuildTasks`.
Controls scaffolding helpers live under `/tools/controls/ControlGeneration/scripts`.
Controls release helper scripts live under `/tools/controls/Release/scripts`.
Controls resource generation helpers live under `/tools/controls/ResourceGeneration/scripts`.
Controls developer shell helpers and command implementation live under
`/tools/controls/Shell/scripts`.
Controls shared command wrappers live under `/tools/controls/Common/scripts`.
Controls packaging helpers live under `/tools/controls/Packaging/scripts`.
Controls source maintenance helpers live under `/tools/controls/SourceMaintenance/scripts`.
Controls test app deployment, installation, and dependency helpers live under `/tools/controls/TestAppDeployment/scripts`.
Controls test reporting helpers live under `/tools/controls/TestReporting/scripts`.
Controls XAML processing and WinUI 2 migration helpers live under `/tools/controls/XamlProcessing/scripts`.

## /docs
This is where the repo documentation lives, including this document.
Repository policy and notice files such as security, contribution, code of
conduct, and privacy documentation live directly under `/docs`.
Feature and API design specs live under `/docs/specs`, with API review specs
under `/docs/specs/api`.
Developer workflows are grouped by purpose under folders such as
`/docs/building`, `/docs/testing`, `/docs/debugging`, `/docs/publishing`,
and `/docs/external`. Architecture and design notes are grouped under
`/docs/design-notes`, including control-specific design notes under
`/docs/design-notes/controls`. WebView2 build/run guidance lives under
`/docs/building`, WebView2 UIA and accessibility notes live under
`/docs/design-notes/input`, and WebView2 dependency update and version-history
docs live under `/docs/publishing`.

Note that developer usage documentation can be found separately on docs.microsoft.com.

## /eng
All build system and other engineering related files go in this directory.
For more information on the build system, see the [build system design](building/build-system-design.md)
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
Package layout build rules live under `/eng/packaging`, and WinUI package
construction inputs live under `/eng/packaging/winui`.
Product metadata item definitions live under `/eng/productmetadata`.
In-repo XAML compiler consumption hooks and helper build projects live under
`/eng/xamlcompiler`.
WinRT class registration build rules live under `/eng/winrtclassregistration`.
WinUIDetails package import rules live under `/eng/winuidetails`.

## Checked-In Dependencies And Generated Assets
Header-only third-party dependencies live under `/src/thirdparty/include`.
Generated controls dependency-property sources live under `/src/controls/generated/dependencyproperties`.
Runtime generated controls headers live under `/src/runtime/generated/core/controls`.
Generated package IntelliSense XML lives under `/eng/packaging/intellisense/generated`.
Visual test baselines live under `/tests/visualbaselines`.

## /src
This is where source code for repo-local tools and source components outside the
runtime and controls trees live.

The XAML compiler now lives under `/src/compiler`. That folder contains the
compiler build tasks, executable host, parsing projects, MSBuild targets, and
compiler-specific tools and solutions.

The WinUI controls implementation now lives under `/src/controls`. Controls
IDL inputs live under `/src/controls/idl`. Controls solution and build-support
entry points live under `/src/controls` and `/eng/controls`, and refer to the
source tree through `$(MUXControlsSourceRoot)`.

The Microsoft.UI.Xaml.dll runtime implementation now lives under
`/src/runtime/xcp`, with runtime solution entry points and phone-specific source
also under `/src/runtime`.
Runtime test package inputs live under `/tests/runtime/packages`, including
AppX manifest inputs and the temporary WebView2 Runtime installer staging path.

Metadata composition projects now live under `/src/metadata`. The MergedWinMD
projects are referenced through `$(MergedWinMDProjectRoot)`.

The WinUI C#/WinRT projection projects live under `/src/projection`, with public
type-forwarder sources under `/src/projection/TypeForwarders`.

## /tests
This folder contains test assets that have been separated from product source
trees. Compiler test entry points and support tools live under
`/tests/compiler`; controls test apps and infrastructure live under
`/tests/controls`; shared test payload and Helix infrastructure lives under
`/tests/infra`; runtime test tools live under `/tests/runtime/tools`; runtime
test resources live under `/tests/runtime/resources`, with resource maintenance
helpers under `/tests/runtime/resources/scripts`; runtime test package
maintenance helpers live under
`/tests/runtime/packages/*/scripts`.
