# Loader Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Value-type vocabulary for the dynamic loader — library handles, symbol-lookup scopes, binary-section names and bounds, and typed loader errors — with zero platform dependencies.

---

## Quick Start

`Loader` is the value-type vocabulary for dynamic linking: the typed shapes for library handles, symbol-lookup scopes, binary-section identifiers, and the bytes a section exposes. It holds the *shapes* only — no `dlopen`, no `dlsym`, no C imports — so the same values travel unchanged from a platform package that performs the loader calls (POSIX / Darwin / Windows) through every layer that consumes them.

```swift
import Loader_Primitives

// Symbol resolution is scoped. The two sentinels never own a closable library —
// they say *where* to resolve a name, not *which* handle to close.
let anywhere: Loader.Symbol.Scope = .default   // every loaded image (RTLD_DEFAULT)
let afterCaller: Loader.Symbol.Scope = .next   // the next definition (RTLD_NEXT) — interposition

// A section name resolves to the right on-disk format for the target binary:
// a Mach-O segment+section, an ELF name, or a PE name.
let tests = Loader.Section.Name.swiftTestContent
let types = Loader.Section.Name.swiftTypeMetadata
```

The section payoff is safe, bounds-checked access to discovered bytes — no raw-pointer arithmetic, with lifetime enforced by the compiler:

```swift
import Loader_Primitives

// A platform package enumerates an image's sections and hands back `Bounds`.
// `withBytes` exposes a safe `Span<UInt8>` over the section's raw bytes.
func byteCount(of bounds: Loader.Section.Bounds) -> Int {
    bounds.withBytes { bytes in bytes.count }
}

// Failures are typed and carry a platform message (dlerror / GetLastError):
let failure: Loader.Error = .symbol(Loader.Message(ascii: "undefined symbol"))
```

`Loader.Library.Handle` wraps the platform handle (`void*` from `dlopen`, `HMODULE` from `LoadLibrary`); `Loader.Symbol.Scope` distinguishes a closable handle from the lookup-only `.default` / `.next` sentinels; `Loader.Section.Name` carries the Mach-O / ELF / PE section identifier; and `Loader.Section.Bounds` exposes the section bytes through `span`, `withSpan(_:)`, and `withBytes(_:)`. Runtime discovery and the actual `dlopen` / `dlsym` / section-enumeration calls live in downstream platform packages; this package is the shared vocabulary they populate.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-loader-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Loader Primitives", package: "swift-loader-primitives"),
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

One library product. Depends only on the `String`, `Ownership`, and `ASCII` primitives.

| Product | Target | Purpose |
|---------|--------|---------|
| `Loader Primitives` | `Sources/Loader Primitives/` | The `Loader` namespace: `Loader.Library.Handle`; `Loader.Symbol.Scope`; `Loader.Section` with `Name` (Mach-O / ELF / PE identifiers, plus the well-known `swiftTestContent` / `swiftTypeMetadata` sections) and `Bounds` (safe `span` / `withBytes` access); and the typed `Loader.Error` / `Loader.Message`. |

Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
