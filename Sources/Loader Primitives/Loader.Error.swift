extension Loader {

    public enum Error: Swift.Error, Sendable {

        case open(Message)

        case close(Message)

        case symbol(Message)

        case section(Message)
    }
}
