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
    /// Errors from dynamic loader operations.
    ///
    /// Captures error information from platform loader APIs
    /// (dlerror on POSIX, GetLastError on Windows).
    public enum Error: Swift.Error, Sendable {
        /// Failed to open a dynamic library.
        ///
        /// - Parameter message: Platform-specific error message.
        case open(Message)

        /// Failed to close a dynamic library.
        ///
        /// - Parameter message: Platform-specific error message.
        case close(Message)

        /// Failed to look up a symbol.
        ///
        /// - Parameter message: Platform-specific error message.
        case symbol(Message)

        /// Failed to enumerate or access a section.
        ///
        /// - Parameter message: Platform-specific error message.
        case section(Message)
    }
}

// Loader.Message is declared in Loader.Message.swift (single-type-per-file).
