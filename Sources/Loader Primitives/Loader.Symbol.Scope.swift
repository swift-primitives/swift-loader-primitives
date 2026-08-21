extension Loader.Symbol {

    @unsafe
    public enum Scope: Sendable, Equatable {

        case handle(Loader.Library.Handle)

        case `default`

        case next
    }
}

extension Loader.Symbol.Scope {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch unsafe (lhs, rhs) {
        case (.handle(let lh), .handle(let rh)):
            return unsafe lh == rh

        case (.default, .default):
            return true

        case (.next, .next):
            return true

        default:
            return false
        }
    }
}
