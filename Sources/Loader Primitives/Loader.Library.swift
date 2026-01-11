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

extension Loader {
    /// Dynamic library loading interface.
    ///
    /// Provides the ability to load and unload dynamic libraries at runtime.
    ///
    /// ## Thread Safety
    ///
    /// - `open` is thread-safe (OS provides synchronization)
    /// - `close` is NOT thread-safe with concurrent symbol lookups on the same handle
    /// - Caller MUST externally synchronize `close` vs in-flight symbol lookups
    ///
    /// ## Handle Lifetime
    ///
    /// After `close(handle)`, the handle is invalid and must not be used.
    /// Any symbol pointers obtained from this library are also invalid.
    public enum Library: Sendable {}
}
