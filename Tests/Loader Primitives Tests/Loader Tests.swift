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

import Testing

@testable import Loader_Primitives

extension Loader {
    @Suite struct Tests {
        @Test func `namespace is available`() {
            // Minimal smoke test — the real suite is authored during flip-prep.
            #expect(Bool(true))
        }
    }
}

extension Loader.Section.Name {
    @Suite struct Tests {

        // MARK: Content-based equality

        @Test func `equal content from distinct literals compares equal and hashes equal`() {
            // Literals spelled in this module; the well-known constant's
            // literals live in the library module. Whether or not the linker
            // coalesces them, equality must hold by content.
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
            // A unicode-scalar-literal StaticString stores its contents
            // inline (no pointer representation), so the two identifiers are
            // guaranteed to be backed by distinct storage. Address-based
            // comparison cannot even inspect the scalar form.
            // REASON: deliberately constructing the scalar-literal storage form to prove content equality is independent of representation.
            // swiftlint:disable:next compiler_protocol_init
            let inline = Loader.Section.Name(elf: StaticString(unicodeScalarLiteral: "t"))
            let pointer = Loader.Section.Name(elf: "t")

            #expect(inline == pointer)
            #expect(pointer == inline)
            #expect(inline.hashValue == pointer.hashValue)
        }

        // MARK: Controls

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
