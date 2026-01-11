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

extension Loader.Library {
    /// Opaque handle to a loaded dynamic library.
    ///
    /// Returned by `open`, consumed by `close`. This type represents
    /// an actual loaded library, NOT a lookup sentinel.
    ///
    /// ## Thread Safety
    ///
    /// Handle values can be safely passed between threads (`Sendable`).
    /// However, callers must externally synchronize `close` vs in-flight
    /// symbol lookups on the same handle.
    ///
    /// ## Validity
    ///
    /// After `close(handle)`, the handle is invalid and must not be used.
    /// Any symbol pointers obtained from this library are also invalid.
    ///
    /// ## Platform Notes
    ///
    /// - POSIX: wraps `void*` from `dlopen`
    /// - Windows: wraps `HMODULE` from `LoadLibrary`
    public struct Handle: @unchecked Sendable, Equatable {
        /// The underlying platform-specific handle.
        ///
        /// - POSIX: `void*` from dlopen
        /// - Windows: `HMODULE` from LoadLibrary
        public let rawValue: UnsafeMutableRawPointer

        /// Creates a handle from a raw pointer.
        ///
        /// - Parameter rawValue: The platform-specific handle value.
        @inlinable
        public init(rawValue: UnsafeMutableRawPointer) {
            self.rawValue = rawValue
        }
    }
}
