import Testing

@testable import Loader_Primitives

extension Loader {
    @Suite struct Tests {
        @Test func `namespace is available`() {

            #expect(Bool(true))
        }
    }
}

extension Loader.Section.Name {
    @Suite struct Tests {

        @Test func `equal content from distinct literals compares equal and hashes equal`() {

            let reconstructed = Loader.Section.Name(
                machO: (segment: "__DATA_CONST", section: "__swift5_tests"),
                elf: "swift5_tests",
                pe: ".sw5test$B"
            )

            #expect(reconstructed == .swiftTestContent)
            #expect(reconstructed.hashValue == Loader.Section.Name.swiftTestContent.hashValue)
        }

        @Test func `equal content across storage representations compares equal and hashes equal`()
        {

            let inline = Loader.Section.Name(elf: StaticString(unicodeScalarLiteral: "t"))
            let pointer = Loader.Section.Name(elf: "t")

            #expect(inline == pointer)
            #expect(pointer == inline)
            #expect(inline.hashValue == pointer.hashValue)
        }

        @Test func `different content compares unequal`() {
            let a = Loader.Section.Name(elf: "swift5_tests")
            let b = Loader.Section.Name(elf: "swift5_type_metadata")

            #expect(a != b)
            #expect(Loader.Section.Name.swiftTestContent != .swiftTypeMetadata)
        }

        @Test func `defined and undefined identifiers compare unequal`() {
            let machOOnly = Loader.Section.Name(
                machO: (segment: "__DATA", section: "__swift5_tests")
            )
            let elfOnly = Loader.Section.Name(elf: "swift5_tests")

            #expect(machOOnly != elfOnly)
            #expect(Loader.Section.Name.swiftTestContent != .swiftTestContentFallback)
        }
    }
}
