# The Repository Structure

This repository contains the **WinUI (Windows UI Library)** — the native UI framework for Windows apps. It provides both the XAML rendering engine (the core framework) and a large set of modern controls built on top of it.

```
.
/src
├── build/                                 # Shared MSBuild props/targets and SDK download scripts
├── controls/                              # WinUI controls
├── dbgext/                                # WinDbg/LLDB debugger extension for XAML
├── dxaml/                                 # WinUI XAML framework
│   └── xcp/
│       ├── common/                        # 
│       ├── components/                    # Modular engine subsystems
│       ├── control/                       # 
│       ├── core/                          # Central XAML engine
│       ├── dxaml/                         # WinRT public API layer
│       │   ├── idl/                       # IDL definitions for all public WinRT interfaces
│       │   ├── lib/                       # C++/WinRT partial-class implementations for all framework types
│       │   ├── themes/                    # Default XAML resource dictionaries and control templates
│       │   ├── manifest/                  # DLL manifest
│       │   └── tools/                     # Code-gen tools for the API layer
│       ├── host/                          # 
│       ├── inc/                           # Top-level shared include headers
│       ├── pal/                           # Platform abstraction layer
│       ├── plat/                          # OS-specific platform implementations
│       ├── tools/                         # Tools for XBF (XBF parser, dumper, etc)
│       └── win/                           # 
├── eng/                                   # 
├── external/                              # External dependency sources
├── MergedWinMD/                           # 
├── PackageStore/                          # Local package cache
├── packaging/                             # NuGet packaging definitions and manifests
├── perf/                                  # Build configuration definition for PGO
├── scripts/                               # Developer and CI helper scripts
├── src/                                   # Microsoft.UI.Xaml.Markup.Compiler source
└── tools/                                 # Repo-wide build tools and code generators
```

## `/controls`

This folder controls the library of WinUI controls and their styles.

```
.
├── dev/                               # Per-control source (one folder per control)
│   ├── <controls>
│   ├── dll/                           # Controls DLL entry point
│   └── inc/                           # Shared internal headers
├── idl/                               # Public API IDL definitions
├── test/                              # Control test projects
└── tools/                             # Code-generation and build tools
```

## `dxaml/xcp/core`

This folder contains the core XAML engine.

```
.
├── Parser/                    # XAML markup parser
├── animation/                 # Animation engine
├── common/                    # Core shared utilities
├── compositor/                # Visual compositor integration
├── controls/                  # Core built-in control implementations
├── core/                      # Root object model and tree
├── dethunk/                   # ABI thunking layer
├── error/                     # Error handling
├── hw/                        # Hardware-accelerated rendering
├── imaging/                   # Image decoding and management
├── input/                     # Input processing
├── layout/                    # Layout engine
├── metadata/                  # Type metadata system
├── native/                    # Native interop
├── networking/                # Network resource loading
├── optional/                  # Optional platform feature stubs
├── packaging/                 # App package resource integration
├── sw/                        # Software rendering fallback
└── text/                      # Text layout and rendering
```

## `dxaml/xcp/components`

This folder contains modular engine subsystems.

```
.
├── AccessKeys/                # Access key (Alt-key) support
├── CValue/                    # Variant value type (CValue)
├── Collection/                # Observable and UI element collections
├── ContentRoot/               # Input manager and content root
├── DependencyObject/          # Dependency property system
├── DesktopUtility/            # Desktop-specific helpers
├── ExtMetadataProvider/       # External metadata provider
├── FocusRect/                 # Focus rectangle rendering
├── ItemIndexRangeHelper/      # Item index range utilities
├── KeyboardAccelerator/       # Keyboard accelerator support
├── OneCoreTransforms/         # OneCoreTransforms display integration
├── SatelliteBase/             # Satellite DLL infrastructure
├── Switcher/                  # Platform feature switcher
├── Telemetry/                 # Engine telemetry
├── UIBridgeFocus/             # Focus bridge for XAML Islands
├── WindowChrome/              # Window chrome / non-client area
├── XboxUtility/               # Xbox-specific utilities
├── allocation/                # Custom allocators
├── animation/                 # Animation component layer
├── associative/               # Associative storage helpers
├── base/                      # Base classes and macros
├── brushes/                   # Brush types
├── colors/                    # Color parsing and management
├── com/                       # COM infrastructure helpers
├── common/                    # Cross-component shared code
├── comptree/                  # Composition tree management
├── controls/                  # Component-layer control helpers
├── criticalsection/           # Lock primitives
├── deferral/                  # Async deferral support
├── dependencyLocator/         # Service locator for DI
├── diagnosticsInterop/        # XAML diagnostics interop
├── elements/                  # UIElement component types
├── eventArgs/                 # Event argument types
├── experimental/              # Experimental/preview features
├── flyweight/                 # Flyweight object patterns
├── focus/                     # Focus management
├── gestures/                  # Gesture recognizer
├── graphics/                  # Graphics primitives
├── imaging/                   # Image subsystem component
├── input/                     # Input pipeline component
├── inputpane/                 # On-screen keyboard input pane
├── legacy/                    # Legacy compatibility code
├── lifetime/                  # Object lifetime management
├── livereorderhelper/         # Live-reorder animation helper
├── math/                      # Math utilities
├── metadata/                  # Metadata component layer
├── moco/                      # Mock/stub component helpers
├── mrt/                       # MRT resource loading
├── namescope/                 # XAML name scope
├── objectWriter/              # XAML object writer
├── offerableheap/             # Offerable memory heap
├── parser/                    # Component-layer XAML parser
├── perf_guard/                # Performance guard assertions
├── pivot/                     # Pivot control component
├── primitiveDependencyObjects/# Primitive DO types (bool, int…)
├── qualifiers/                # Resource qualifiers (scale, theme…)
├── relativepanel/             # RelativePanel constraint solver
├── resources/                 # Resource dictionary component
├── runtimeEnabledFeatures/    # Runtime feature flags
├── scaling/                   # Display scaling helpers
├── simple/                    # Simple value types
├── staticpal/                 # Static PAL initialization
├── style/                     # Style and setter component
├── terminateProcessOnOOM/     # OOM safety handler
├── text/                      # Text component layer
├── themeanimationshelper/     # Theme animation helpers
├── theming/                   # Theme resource management
├── theminginterop/            # Theming interop with the OS
├── threading/                 # Threading utilities
├── transforms/                # Transform types
├── valueboxer/                # Value boxing/unboxing
├── visualstateshelper/        # Visual state helper utilities
├── vsm/                       # Visual State Manager
├── winuri/                    # URI parsing helpers
├── xamlDiagnostics/           # XAML live diagnostics
└── xstring/                   # Optimized XAML string type
```
