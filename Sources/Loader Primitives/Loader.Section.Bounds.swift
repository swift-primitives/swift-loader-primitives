extension Loader.Section {

    @safe
    public struct Bounds: Sendable {

        @unsafe

        nonisolated(unsafe) public let imageAddress: UnsafeRawPointer?

        @unsafe

        nonisolated(unsafe) public let buffer: UnsafeRawBufferPointer

        @inlinable
        public init(
            imageAddress: UnsafeRawPointer?,
            buffer: UnsafeRawBufferPointer
        ) {
            unsafe (self.imageAddress = imageAddress)
            unsafe (self.buffer = buffer)
        }
    }
}

extension Loader.Section.Bounds {

    @inlinable
    public var span: RawSpan {
        @_lifetime(borrow self)
        borrowing get {
            unsafe RawSpan(_unsafeBytes: buffer)
        }
    }

    @inlinable
    public borrowing func withSpan<R, E: Swift.Error>(
        _ body: (RawSpan) throws(E) -> R
    ) throws(E) -> R {
        try body(span)
    }

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
