// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-loader open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-loader project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Loader.Symbol {
    /// Lookup scope for symbol resolution.
    ///
    /// Specifies where to search when looking up a symbol.
    ///
    /// ## Design
    ///
    /// This enum separates closable library handles from lookup-only sentinels.
    /// Special scopes (`.default`, `.next`) are NOT closable — they are
    /// lookup sentinels, not library handles.
    ///
    /// ## Pointer Lifetime
    ///
    /// - For `.handle(h)`: returned pointer validity is bounded by that handle's lifetime
    /// - For `.default`/`.next`: lookups are not tied to a specific library lifetime,
    ///   but returned pointers can be invalidated by unloading a library that owns the symbol
    /// - **Never assume** `.default` means "stable forever"
    @unsafe
    public enum Scope: Sendable, Equatable {
        /// Search in a specific loaded library.
        ///
        /// Use this when you have a handle from `Loader.Library.open`.
        case handle(Loader.Library.Handle)

        /// Search default library paths (RTLD_DEFAULT on POSIX).
        ///
        /// Finds symbol in any loaded library, following load order.
        /// On Darwin, includes main executable and all linked libraries.
        /// On Linux, searches all loaded shared objects.
        case `default`

        /// Search in next library after caller (RTLD_NEXT on POSIX).
        ///
        /// Used for interposition/wrapping: finds the next occurrence
        /// of a symbol in the load order after the current object.
        case next

        public static func == (lhs: Self, rhs: Self) -> Bool {
            switch unsafe (lhs, rhs) {
            case let (.handle(lh), .handle(rh)):
                return unsafe lh == rh
            case (.default, .default):
                return true
            case (.next, .next):
                return true
            default:
                return false
            }
        }
    }
}
