# Architectural issues

This assessment is based on the repository structure, all repository Markdown documentation, and targeted inspection of the implementation and build graph. It distinguishes documented limitations from inferences supported by repository-wide measurements.

## Executive summary

| Priority | Issue | Primary consequence |
| --- | --- | --- |
| High | Historical DXaml/Core split and peer objects | Every control crosses an obsolete layer boundary, increasing coupling and change cost. |
| High | Thread-scoped global state and incomplete restart semantics | Startup, shutdown, hosting, and test isolation remain difficult to reason about. |
| High | Ownership across COM, WinRT, and CLR | Reference cycles can leak, while incorrect weakening can cause premature collection. |
| High | Reentrancy and multi-window assumptions | Correctness depends on implicit UI-thread, dispatcher, focus, and window-root context. |
| Medium-high | UI-thread scheduling and duplicated dispatch machinery | Latency-sensitive work has fragile scheduling paths and retained obsolete mechanisms. |
| Medium-high | Implicit, repository-wide build configuration | Import order and directory placement can affect hundreds of projects indirectly. |
| Medium-high | Generated ABI/metadata surface and runtime variants | A small API or behavior change fans out across generated artifacts and feature combinations. |
| Medium | Windows App SDK feeder and packaging boundary | Release correctness depends on cross-repository aggregation and duplicated package shapes. |
| Medium-high | Environment-coupled and unreliable test system | Refactoring feedback is slow, OS-dependent, and sometimes non-deterministic. |
| Medium | Architecture and specification drift | Design authority is fragmented, making safe decisions and automated validation harder. |

## Findings

### 1. Historical DXaml/Core split and peer objects

Each public control is represented by both a DXaml object and a Core object. The design document says the layers were once in separate DLLs, are now in one DLL, and retain abstractions because direct inclusion would expose circular dependencies. It also explicitly says the old `CoreImports.cpp` indirection should be removed. See [DXaml vs Core layers and peer objects](design-notes/dxamlvscore.md#peer-objects).

The implementation still reflects this boundary heavily: the current scan finds 991 lines calling `DXamlCore::GetCurrent()`, 2,272 lines referencing `CCoreServices`, and 550 lines referencing `FxCallbacks` under `dxaml`.

Impact:

- Object identity and lifetime must remain synchronized across two representations.
- Cross-layer work relies on casts, handles, callbacks, and service locators instead of ordinary typed dependencies.
- Features tend to cut across both layers, increasing the blast radius of changes.

Direction: define and enforce a target dependency direction, place a narrow façade around the remaining boundary, then remove obsolete `CoreImports`/callback paths one vertical feature at a time.

### 2. Thread-scoped global state and incomplete restart semantics

Core access commonly flows through `DXamlCore::GetCurrent()`, while `WindowsXamlManager` tracks per-thread state. The shutdown design records that process restart is still unsupported and that `Application`/`WindowsXamlManager` startup remains entangled. It also describes a permanent memory tax after first use of XAML Islands. See [XAML shutdown problems](design-notes/xaml-shutdown.md#problems-in-system-xaml-islands-lifetime--shutdown) and [the application model](design-notes/app-model.md#shutdown-models-we-could-delete-the-old-one).

Impact:

- Dependencies and valid call context are implicit rather than visible in APIs.
- Hosting, unloading, multiple UI threads, and test isolation need special lifecycle rules.
- Old and new shutdown models coexist, preserving branches that are hard to exercise comprehensively.

Direction: model lifecycle as one explicit state machine, delete the legacy shutdown path after telemetry-backed validation, pass a scoped core/context object through subsystem boundaries, and add restart/unload contract tests.

### 3. Ownership across COM, WinRT, and CLR

The lifetime design explains that cycles involving XAML/WinRT objects can leak even in C#, while weakening the wrong reference can collect callbacks too early. XAML therefore participates in CLR collection through reference-tracker interfaces. See [XAML/C# object lifetime](design-notes/xaml-object-lifetime.md#the-problem).

Impact:

- Memory safety depends on a non-local graph protocol spanning multiple runtimes.
- Ordinary event handlers and lambda captures can change lifetime behavior.
- Leak diagnosis and teardown correctness require framework-specific expertise.

Direction: document ownership categories at API boundaries, centralize tracker/peg operations behind typed wrappers, add graph-shaped lifetime tests, and make leak/restart tests part of the normal subsystem test tier.

### 4. Reentrancy and multi-window assumptions

The reentrancy design states that Windows App SDK uses STA and does not inherit ASTA's protections against categories of reentrancy bugs and deadlocks. The focus design explicitly calls multi-window-on-one-thread behavior technical debt from breaking the original one-window-per-thread assumption. See [reentrancy](design-notes/reentrancy.md#asta-vs-sta-threading-models) and [XAML Island focus navigation](design-notes/xaml-islands/xaml-island-focus-navigation.md#the-win32-set-focus).

Impact:

- Synchronous callbacks can enter partially updated framework state.
- Focus, input, dispatcher, and content-root code must infer which tree/window is current.
- Safety is maintained by scattered guards, blocked messages, and special cases.

Direction: make window/content-root and dispatcher context explicit, define subsystem reentrancy contracts, reduce synchronous framework-to-app callbacks, and run systematic nested-message-loop and multi-window tests.

### 5. UI-thread scheduling and duplicated dispatch machinery

The scheduling design labels retained render-thread locks and old scheduling algorithms as defunct and confusing, and calls the `WaitForVBlank` optimization fragile. The imaging design describes two synchronization task classes plus a custom UI-thread dispatcher that could be simplified. See [scheduling](design-notes/scheduling.md#defunct-confusing-code) and [imaging](design-notes/imaging.md#decode).

Impact:

- Layout, input, animation, decode completion, and rendering compete for one latency-sensitive thread.
- Multiple scheduling abstractions make ordering, cancellation, shutdown, and performance behavior harder to predict.
- Obsolete locks and algorithms obscure the live concurrency model.

Direction: remove dead scheduling paths, consolidate UI/background dispatch behind one cancellation-aware abstraction, and establish trace-based frame, layout, and image-pipeline budgets.

### 6. Implicit, repository-wide build configuration

The build design calls MSBuild import order one of its trickiest concerns and acknowledges that auto-imported `Directory.Build.*` files can create “magic” and couple repository layout to build behavior. The repository currently contains 330 C++ projects, 137 C# projects, 150 `.props` files, and 92 `.targets` files. See [build system design](../development/building/build-system-design.md#managing-import-order).

Impact:

- Moving a project or editing a shared property can silently change a large part of the graph.
- Project boundaries do not necessarily provide configuration isolation.
- Incremental-build behavior depends on coupled metadata properties.

Direction: publish a machine-readable project-layer graph, validate forbidden dependencies in CI, reduce root imports to stable primitives, and expose opt-in capability packages for specialized build behavior.

### 7. Generated ABI/metadata surface and runtime variants

Adding one public property can require IDL, runtime implementation, parser metadata, XBF indexes, manifests, and generated framework/core partials. The scan finds 2,991 paths containing `generated` or `autogen` and 245 IDL files. Runtime-enabled behavior is also selected at more than 100 implementation call sites, with enum and data tables that must remain synchronized. See [code generation](design-notes/codegen.md#what-does-the-code-generator-generate), [Fast ABI](design-notes/fastabi.md#background), and [runtime-enabled features](runtime-enabled-features.md#adding-a-new-runtime-enabled-feature).

Impact:

- Source-of-truth drift can surface as ABI, metadata, parser, or packaging defects.
- Feature flags multiply runtime states and test combinations.
- Checked-in generated output makes reviews and merges noisier.

Direction: converge on one declarative API model, validate generated artifacts from that model, assign every feature flag an owner and removal release, and test supported flag combinations rather than ad hoc overrides.

### 8. Windows App SDK feeder and packaging boundary

WinUI is a feeder repository whose transport package has substantially similar content to the standalone package, then gets split and aggregated by the Windows App SDK pipeline. See [Windows App SDK integration](windows-app-sdk-integration.md#winui-3-transport-package).

Impact:

- Package layout, versioning, and release failures can cross repository and pipeline boundaries.
- Inner-loop, transport, framework, thin-package, monolithic-package, and self-contained shapes can diverge.
- Some of the integration documentation already points to removed packaging inputs, indicating contract drift.

Direction: define a versioned transport manifest, validate every produced package shape from one artifact inventory, and run consumer contract tests at the feeder/aggregation boundary.

### 9. Environment-coupled and unreliable test system

Tests depend on specific Windows versions, dedicated VM pools, packaging/deployment, UI-thread execution, and a multi-stage payload pipeline. The testing FAQ states that tests are not fully reliable, uses retry as mitigation, and allows disabling unstable tests. See [test system overview](../development/testing/test-system-overview.md#build-infrastructure-and-agent-pools) and [testing FAQ](../development/testing/testing-FAQ.md#my-pr-build-failed-due-to-a-test-failure-unrelated-to-my-change-what-do-i-do).

Impact:

- Feedback is slower than a hermetic unit-test loop and failures can be ambiguous.
- Retries and disabled tests reduce confidence in architectural refactoring.
- Stale Helix terminology and missing pipeline references show that implementation and documentation evolve separately.

Direction: separate hermetic component tests from packaged/OS integration tests, publish flake ownership and budgets, quarantine rather than silently disable, and make test orchestration metadata the source for generated documentation.

### 10. Architecture and specification drift

Before consolidation, repository documentation was spread across four main roots and multiple component source directories. After correcting relocation errors and several obvious stale references, the consolidated local link scan still reports 142 pre-existing issues: 25 missing file targets and 117 invalid heading anchors. The corpus also contains 22 `TODO`, 9 `TBD`, and multiple parallel versions of InfoBadge, TitleBar, scrolling, and API-review specifications.

Impact:

- Engineers cannot reliably identify the canonical design or current implementation contract.
- Stale links conceal deleted source, pipeline, package, and sample dependencies.
- Design decisions are difficult to validate automatically or retire deliberately.

Direction: assign owners and status metadata to architecture/spec documents, declare canonical documents and replace copies with redirects, require local-link validation for the entire documentation tree, and review documents on the same cadence as their owning subsystem.

## Recommended sequence

1. Stabilize lifecycle, ownership, and reentrancy invariants with focused tests; these are the highest correctness risks.
2. Establish enforceable DXaml/Core and project-graph boundaries before large code movement.
3. Remove the legacy shutdown and defunct scheduling paths behind telemetry and rollback criteria.
4. Consolidate API metadata generation and retire stale runtime flags.
5. Harden feeder-package contracts and split fast hermetic tests from OS integration coverage.
6. Make architecture ownership, canonical status, and link validation part of CI.
