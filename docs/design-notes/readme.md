# Code architecture documentation

This is a collection of documentations which provide a high level design oriented overview of different parts of WinUI codebase. It is an ongoing effort, so expect large scale changes to content as well as format.

## Contents:

### Concepts

* [Journey of a control](./architecture/control-overview.md) - a vertical slice of what makes up a WinUI control
* [Consolidating the Microsoft.UI namespace to one package](./architecture/consolidate-microsoft-ui-namespace.md)
* [Lightweight Bindings](./data-binding/lightweight-bindings.md)
* [Property Path Binding Architecture](./data-binding/PropertyPathBindingArchitecture.md)
* [Xaml compiler overview](./xaml-compiler/xamlcompiler.md)
* [Codegen](./xaml-compiler/codegen.md)
* [Xaml/C# Object Lifetime Design](./runtime-core/xaml-object-lifetime.md)
* [Property System](./runtime-core/property-system.md)
* [Runtime Enabled Features](./runtime-core/runtime-enabled-features.md)
* [Surfaces in Xaml](./rendering/surfaces-overview.md) - Use of Composition and Direct3D surfaces in Xaml
* [Dxaml vs Core layers / Peer objects](./runtime-core/dxamlvscore.md) - A writeup explaning difference between Dxaml and core layers, peer objects and how to transition between the two objects for a given type
* [XAML Rendering Architecture](./rendering/rendering.md) -  This document gives a high-level overview of how the XAML rendering engine works, primarily covering integration with the system compositor
* [UI Thread ticking](./rendering/ui-thread-ticking.md) - A writeup on ticks in ui thread and how layout, animation and other parts of UI depend on it
* [Xaml theming resources](./resources/resources.md) - A writeup on everthing about Xaml theming resources and how they are created and used
* [Read-Only Text Controls Architecture](./text/text-controls.md) - This document describes the architecture of XAML’s read-only text controls, and supporting functionality in the XAML platform to make them fully functional in a XAML application.
* [Custom titlebar](./styling/customtitlebar.md) - Explains the inner working of custom titlebar feature in Desktop WinUI 3 apps, including glass window concept
* [Unconstrained Popups](./popups/unconstrained-popup.md) - A spec about a new(er) option for ContentDialogPlacement: UnconstrainedPopup
* [ItemsRepeater overview](./collection-controls/ItemsRepeater-overview.md)
* [ItemsView/ItemContainer overviews](./collection-controls/ItemsView-ItemContainer-overview.md)
* [ListView/GridView overview](./collection-controls/ListView-GridView-overview.md)
* [Hit Testing](./input/hit-testing.md)

### Coding resources

* [Guide to WinUI codebase pointers](./developer-guides/pointers.md)
* [DebugSettings](./developer-guides/debug-settings.md)
* [Startup path for WinUI application](./app-lifecycle/startup-overview.md)
* [Xaml Behaviors](./developer-guides/xamlbehaviors.md) - Lists deprecated features which are still in codebase and getting slowly phased out
