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
    /// Error message from loader operations.
    ///
    /// Captures the error message from dlerror() or Windows GetLastError.
    /// Stores the message as a boxed platform string for copyability across error handling.
    ///
    /// - Note: `CustomStringConvertible` conformance is provided in Foundations
    ///   via swift-strings bridging.
    public struct Message: Sendable {
        /// The error message text as a boxed platform string.
        public let text: Ownership.Immutable<String_Primitives.String>

        /// Creates an error message from a platform string.
        ///
        /// - Parameter text: The error message text.
        public init(_ text: consuming String_Primitives.String) {
            self.text = Ownership.Immutable(text)
        }

        /// Creates an error message from an ASCII string literal.
        ///
        /// - Parameter literal: The string literal. Must contain only ASCII characters.
        @inlinable
        public init(ascii literal: StaticString) {
            self.text = Ownership.Immutable(String_Primitives.String(ascii: literal))
        }

        /// Creates an error message by copying from a borrowed C string view.
        ///
        /// - Parameter view: A borrowed view of a null-terminated C string.
        @unsafe
        public init(copying view: borrowing String_Primitives.String.Borrowed) {
            self.text = Ownership.Immutable(String_Primitives.String(copying: view))
        }
    }
}
