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

internal import ASCII_Primitives
public import Ownership_Primitives
public import String_Primitives

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

// MARK: - Error Message

extension Loader {
    /// Error message from loader operations.
    ///
    /// Captures the error message from dlerror() or Windows GetLastError.
    /// Stores the message as a boxed platform string for copyability across error handling.
    ///
    /// - Note: `CustomStringConvertible` conformance is provided in Foundations
    ///   via swift-strings bridging.
    public struct Message: Sendable {
        /// The error message text as a boxed platform string.
        public let text: Ownership.Shared<String_Primitives.String>

        /// Creates an error message from a platform string.
        ///
        /// - Parameter text: The error message text.
        public init(_ text: consuming String_Primitives.String) {
            self.text = Ownership.Shared(text)
        }

        /// Creates an error message from an ASCII string literal.
        ///
        /// - Parameter literal: The string literal. Must contain only ASCII characters.
        @inlinable
        public init(ascii literal: StaticString) {
            self.text = Ownership.Shared(String_Primitives.String(ascii: literal))
        }

        /// Creates an error message by copying from a borrowed C string view.
        ///
        /// - Parameter view: A borrowed view of a null-terminated C string.
        @unsafe
        public init(copying view: borrowing String_Primitives.String.Borrowed) {
            self.text = Ownership.Shared(String_Primitives.String(copying: view))
        }
    }
}
