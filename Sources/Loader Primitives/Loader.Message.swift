internal import ASCII_Primitives
public import Ownership_Primitives
public import String_Primitives

extension Loader {

    public struct Message: Sendable {

        public let text: Ownership.Immutable<String_Primitives.String>

        public init(_ text: consuming String_Primitives.String) {
            self.text = Ownership.Immutable(text)
        }

        @inlinable
        public init(ascii literal: StaticString) {
            self.text = Ownership.Immutable(String_Primitives.String(ascii: literal))
        }

        @unsafe
        public init(copying view: borrowing String_Primitives.String.Borrowed) {
            self.text = Ownership.Immutable(String_Primitives.String(copying: view))
        }
    }
}
