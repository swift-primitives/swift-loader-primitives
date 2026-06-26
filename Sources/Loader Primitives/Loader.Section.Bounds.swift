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
    // WHY: Category D (SP-5) — pointer-backed value type; storage is
    // WHY: private/internal; the type's safe API never lets the raw pointer
    // WHY: escape, and lifetime invariants are enforced by init/deinit pairing.
    /// Memory bounds of a section within a loaded image.
    ///
    /// ## Lifetime Contract
    ///
    /// **The span/buffer is valid only for the duration of the iteration.**
    /// Do not store `Bounds` instances or capture data pointers
    /// beyond the scope of the iteration closure or loop body.
    ///
    /// On Darwin, section data is typically stable while the image
    /// remains loaded, but this abstraction enforces a stricter
    /// "consume immediately" contract for portability and safety.
    ///
    /// ## Usage Pattern (Safe - Recommended)
    ///
    /// ```swift
    /// for bounds in Loader.Section.all(.swiftTestContent) {
    ///     // Use span for safe, bounds-checked access
    ///     let rawSpan = bounds.span
    ///     // Access raw bytes via RawSpan API
    ///     print("Section has \(rawSpan.byteCount) bytes")
    ///
    ///     // Or use typed byte access
    ///     bounds.withBytes { bytes in
    ///         for byte in bytes { /* ... */ }
    ///     }
    /// }
    /// ```
    ///
    /// ## Usage Pattern (Unsafe - C Interop)
    ///
    /// ```swift
    /// for bounds in Loader.Section.all(.swiftTestContent) {
    ///     // Use buffer only when C interop requires raw pointers
    ///     unsafe processLegacySection(bounds.buffer)
    /// }
    /// ```
    ///
    /// ## Memory Layout
    ///
    /// The span/buffer provides direct access to the section's raw bytes.
    /// Callers must interpret the contents according to the section's
    /// expected format (e.g., array of test content records).
    @safe
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
        @unsafe
        nonisolated(unsafe) public let imageAddress: UnsafeRawPointer?

        /// The section's memory buffer (unsafe escape hatch).
        ///
        /// **Prefer `span` or `withBytes(_:)` for safe access.** Use this
        /// property only when C interop or legacy APIs require raw pointer access.
        ///
        /// **Valid only during iteration.** See type documentation
        /// for lifetime contract.
        ///
        /// The buffer contains the raw bytes of the section. Callers
        /// are responsible for interpreting the contents according
        /// to the section's expected format.
        @unsafe
        nonisolated(unsafe) public let buffer: UnsafeRawBufferPointer

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
            unsafe (self.imageAddress = imageAddress)
            unsafe (self.buffer = buffer)
        }

        // MARK: - Safe Access (Canonical API)

        /// Safe, bounds-checked view of the section's raw bytes.
        ///
        /// This is the **canonical API** for accessing section data.
        /// The `RawSpan` provides compiler-enforced lifetime safety and
        /// bounds checking with zero runtime overhead.
        ///
        /// - Returns: A `RawSpan` view of the section's bytes.
        ///
        /// ## Example
        ///
        /// ```swift
        /// for bounds in Loader.Section.all(.swiftTestContent) {
        ///     let span = bounds.span
        ///     // Process bytes using span.byteCount, span.unsafeLoad, etc.
        /// }
        /// ```
        @inlinable
        public var span: RawSpan {
            @_lifetime(borrow self)
            borrowing get {
                unsafe RawSpan(_unsafeBytes: buffer)
            }
        }

        /// Provides safe, bounds-checked access to the section's bytes
        /// within a closure.
        ///
        /// Use this method when the property-based `span` accessor
        /// encounters lifetime issues in complex control flow.
        ///
        /// - Parameter body: A closure that receives the span.
        /// - Returns: The value returned by the closure.
        /// - Throws: Any error thrown by the closure.
        ///
        /// ## Example
        ///
        /// ```swift
        /// for bounds in Loader.Section.all(.swiftTestContent) {
        ///     bounds.withSpan { span in
        ///         // Process span within this scope
        ///         for i in 0..<span.byteCount {
        ///             let byte: UInt8 = unsafe span.unsafeLoad(fromByteOffset: i, as: UInt8.self)
        ///             // ...
        ///         }
        ///     }
        /// }
        /// ```
        @inlinable
        public borrowing func withSpan<R, E: Swift.Error>(
            _ body: (RawSpan) throws(E) -> R
        ) throws(E) -> R {
            try body(span)
        }

        /// Safe, bounds-checked view of the section's bytes as typed elements.
        ///
        /// Use this when you need typed element access. For raw byte access,
        /// use the `span` property or `withSpan(_:)` method.
        ///
        /// - Parameter body: A closure that receives the typed span.
        /// - Returns: The value returned by the closure.
        /// - Throws: Any error thrown by the closure.
        ///
        /// ## Example
        ///
        /// ```swift
        /// for bounds in Loader.Section.all(.swiftTestContent) {
        ///     bounds.withBytes { bytes in
        ///         for byte in bytes {
        ///             // Process each byte safely
        ///         }
        ///     }
        /// }
        /// ```
        @inlinable
        public borrowing func withBytes<R, E: Swift.Error>(
            _ body: (Swift.Span<UInt8>) throws(E) -> R
        ) throws(E) -> R {
            guard let baseAddress = unsafe buffer.baseAddress else {
                let emptySpan = Swift.Span<UInt8>()
                return try body(emptySpan)
            }
            let pointer = unsafe baseAddress.assumingMemoryBound(to: UInt8.self)
            let span = unsafe Span(_unsafeStart: pointer, count: buffer.count)
            return try body(span)
        }
    }
}
