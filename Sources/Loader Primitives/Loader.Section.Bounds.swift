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

extension Loader.Section {
    /// Memory bounds of a section within a loaded image.
    ///
    /// ## Lifetime Contract
    ///
    /// **The buffer is valid only for the duration of the iteration.**
    /// Do not store `Bounds` instances or capture `buffer` pointers
    /// beyond the scope of the iteration closure or loop body.
    ///
    /// On Darwin, section data is typically stable while the image
    /// remains loaded, but this abstraction enforces a stricter
    /// "consume immediately" contract for portability and safety.
    ///
    /// ## Usage Pattern
    ///
    /// ```swift
    /// for bounds in Loader.Section.all(.swiftTestContent) {
    ///     // Process bounds.buffer here - do NOT store it
    ///     processSection(bounds.buffer)
    /// }
    /// // bounds.buffer is no longer valid here
    /// ```
    ///
    /// ## Memory Layout
    ///
    /// The buffer provides direct access to the section's raw bytes.
    /// Callers must interpret the contents according to the section's
    /// expected format (e.g., array of test content records).
    public struct Bounds: Sendable {
        /// The base address of the image containing this section.
        ///
        /// The type of this pointer is platform-dependent:
        ///
        /// | Platform | Pointer Type |
        /// |----------|--------------|
        /// | Darwin   | `UnsafePointer<mach_header_64>` |
        /// | Linux    | `UnsafeRawPointer` (ELF header) |
        /// | Windows  | `HMODULE` |
        ///
        /// May be `nil` for statically-linked images or when the
        /// image address is unavailable.
        public nonisolated(unsafe) let imageAddress: UnsafeRawPointer?

        /// The section's memory buffer.
        ///
        /// **Valid only during iteration.** See type documentation
        /// for lifetime contract.
        ///
        /// The buffer contains the raw bytes of the section. Callers
        /// are responsible for interpreting the contents according
        /// to the section's expected format.
        public nonisolated(unsafe) let buffer: UnsafeRawBufferPointer

        /// Creates section bounds.
        ///
        /// - Parameters:
        ///   - imageAddress: Base address of the containing image.
        ///   - buffer: The section's memory buffer.
        @inlinable
        public init(
            imageAddress: UnsafeRawPointer?,
            buffer: UnsafeRawBufferPointer
        ) {
            self.imageAddress = imageAddress
            self.buffer = buffer
        }
    }
}
