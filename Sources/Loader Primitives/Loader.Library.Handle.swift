extension Loader.Library {

    @unsafe
    public struct Handle: @unchecked Sendable, Equatable {

        public let rawValue: UnsafeMutableRawPointer

        @inlinable
        public init(rawValue: UnsafeMutableRawPointer) {
            unsafe (self.rawValue = rawValue)
        }
    }
}

extension Loader.Library.Handle {

    public static func == (lhs: Self, rhs: Self) -> Bool {

        unsafe lhs.rawValue == rhs.rawValue
    }
}
