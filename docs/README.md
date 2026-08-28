# WinUI repository documentation

This directory is the single home for repository documentation. Product usage documentation is maintained separately on [Microsoft Learn](https://learn.microsoft.com/windows/apps/winui/).

## Start here

| Goal | Documentation |
| --- | --- |
| Set up and build the repository | [Getting started with building WinUI](getting-started/building-winui.md) |
| Understand or renew the architecture | [Architectural issues](architecture/architectural-issues.md), [repository structure](architecture/repository-structure.md), and [Windows App SDK integration](architecture/windows-app-sdk-integration.md) |
| Work with the build system | [Developer guide](development/building/developer-guide.md) and [build system how-to](development/building/build-system-howto.md) |
| Run or troubleshoot tests | [Testing FAQ](development/testing/testing-FAQ.md), [test system overview](development/testing/test-system-overview.md), and [debugging guide](development/debugging/debugging.md) |
| Explore repository samples | [OS Framework Lens](samples/os-framework-lens/README.md) and the [TableView sample](samples/table-view.md) |
| Propose a feature or public API | [Feature proposal process](contributing/feature-proposal-process.md) and [public API review process](specifications/features/public-api-review-process.md) |
| Contribute a change | [Contribution workflow](contributing/contribution-workflow.md) and [documentation style](contributing/documentation-style.md) |

## Directory map

```text
docs/
|-- architecture/       System design, subsystem notes, and repository structure
|-- assets/             Shared assets used by developer documentation
|-- components/         Control- and component-specific implementation notes
|-- contributing/       Contribution, triage, proposal, and writing processes
|-- development/        Build, debug, test, performance, and release guides
|-- getting-started/    Initial setup and build instructions
|-- legacy/             Historical implementation notes
|-- legal/              Component-specific legal and privacy notices
|-- samples/            Guides and design notes for repository samples
|-- specifications/     Feature specifications and API proposals
|-- third-party/        Third-party integration notes
|-- tooling/            Repository tool documentation
`-- troubleshooting/    Known problems and diagnostic guides
```

## Main sections

- Architecture: [assessment and renewal priorities](architecture/architectural-issues.md), [property system](architecture/property-system.md), [hit testing](architecture/hit-testing.md), [runtime-enabled features](architecture/runtime-enabled-features.md), [telemetry](architecture/telemetry-events.md), and the [design-note index](architecture/design-notes/readme.md).
- Development: [building](development/building/developer-guide.md), [debugging](development/debugging/debugging.md), [performance](development/performance/perf-how-to.md), [testing](development/testing/testing-FAQ.md), and [releasing](development/releasing/winui3-release-process.md).
- Specifications: [feature specifications](specifications/features/public-api-review-process.md) and [API specifications](specifications/api/api-review-process.md).
- Components: [AnimatedIcon](components/animated-icon/AnimatedIconDevDesign.md), [ColorPicker](components/color-picker/README.md), [NavigationView](components/navigation-view/README.md), [PagerControl](components/pager-control.md), [TeachingTip](components/teaching-tip/focus-behavior.md), and [WebView2](components/webview2/overview.md).
- Tooling: [XAML Profiler](tooling/xaml-profiler/profiler.md), [Xamlsplore](tooling/xamlsplore.md), [custom build tasks](tooling/custom-tasks.md), [baseline resource generation](tooling/mux-baseline-resources-generator.md), and [IntelliSense packaging](tooling/intellisense.md).
- Performance tooling: [XAML launch-telemetry tools](development/performance/tooling/README.md), the [WPA visualizer plugin](development/performance/tooling/app-booting-visualizer-plugin.md), and the [WinUI telemetry viewer](development/performance/tooling/xaml-telemetry-viewer-winui3.md).
- Troubleshooting: [build failures](troubleshooting/build-failures.md), [crashes](troubleshooting/crashes.md), [common errors](troubleshooting/common-errors.md), and [initialization issues](troubleshooting/init-known-issues.md).

## Placement rules

- Add repository documentation under the most specific directory above.
- Keep images beside a narrowly scoped specification, or in `assets/` when multiple developer documents share them.
- Use forward-slash relative links and run the documentation link check before submitting a change.
- Keep only GitHub-recognized community files such as the root `README.md`, `CONTRIBUTING.md`, `SECURITY.md`, and files required by `.github/` outside this directory.

Found a problem? Please file an issue in the [WinUI issue tracker](https://github.com/microsoft/microsoft-ui-xaml/issues).
