# Source code structure

## Table of Contents

- [/build, /tools](#build-tools)
- [/controls](#controls)
- [/docs](#docs)
- [/dxaml](#dxaml)
- [/eng](#eng)
- [/generated](#generated)
- [/src](#src)
- [/tests](#tests)

## /build, /tools
These folders contain scripts and other support machinery that you shouldn't 
need to edit for most changes.

In particular: /build/NuSpecs enables .nupkg generation

## /controls
This folder contains controls solution, IDL, test, and tooling entry points.
The Microsoft.UI.Xaml.Controls.dll implementation source lives under `/src/controls`.

See the [layout refactor notes](building/repo-layout-refactor.md) for more
information about the controls section of the repo.

## /docs
This is where the repo documentation lives, including this document.

Note that developer usage documentation can be found separately on docs.microsoft.com.

## /dxaml
This is where the majority of WinUI source code is. This contains all the test and source code
for Microsoft.UI.Xaml.dll and Microsoft.UI.Xaml.Phone.dll.

## /eng
All build system and other engineering related files go in this directory.
For more information on the build system, see the [build system design](build-system-design.md)

## /generated
This folder contains checked-in generated output and generated baselines.
Generated controls dependency-property sources live under `/generated/controls/dependencyproperties`.
Generated package IntelliSense XML lives under `/generated/packaging/intellisense`.
Visual test baselines live under `/generated/tests/visualbaselines`.

## /src
This is where source code for repo-local tools and source components outside the
runtime and controls trees live.

The XAML compiler now lives under `/src/compiler`. That folder contains the
compiler build tasks, executable host, parsing projects, MSBuild targets, and
compiler-specific tools and solutions.

The WinUI controls implementation now lives under `/src/controls`. Controls
solution, IDL, test, and tooling entry points continue to live under `/controls`
and refer to the source tree through `$(MUXControlsSourceRoot)`.

## /tests
This folder contains test assets that have been separated from product source
trees. Compiler test entry points live under `/tests/compiler`; shared test
payload and Helix infrastructure lives under `/tests/infra`.
