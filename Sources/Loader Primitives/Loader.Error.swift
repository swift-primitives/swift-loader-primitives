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
    public enum Error: Swift.Error, Sendable, Equatable {
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

// MARK: - Error Message

extension Loader {
    /// Error message from loader operations.
    ///
    /// Captures the error message from dlerror() or Windows GetLastError.
    public struct Message: Sendable, Equatable, CustomStringConvertible {
        /// The error message text.
        public let text: String

        /// Creates an error message.
        ///
        /// - Parameter text: The error message text.
        public init(_ text: String) {
            self.text = text
        }

        public var description: String { text }
    }
}
