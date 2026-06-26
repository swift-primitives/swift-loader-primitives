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
    /// Identifies a section within a binary image.
    ///
    /// A name carries the section's identifier in every binary format it is defined
    /// for — Mach-O, ELF, and PE — as cross-platform data. Selecting the right one is
    /// the responsibility of the platform package that consumes it (it reads the
    /// `machO`, `elf`, or `pe` accessor for its own format), not of this primitive.
    /// Use well-known constants like `.swiftTestContent` for portable code.
    ///
    /// ## Platform Representation
    ///
    /// | Platform | Representation |
    /// |----------|---------------|
    /// | Darwin   | Segment + Section (e.g., `__DATA_CONST`, `__swift5_tests`) |
    /// | Linux    | Section name (e.g., `swift5_tests`) |
    /// | Windows  | Section name (e.g., `.sw5test$B`) |
    public struct Name: Sendable, Equatable, Hashable {
        /// The Mach-O (segment, section) identifier, or `nil` if undefined for this name.
        @usableFromInline
        internal let _machO: (segment: StaticString, section: StaticString)?

        /// The ELF section identifier, or `nil` if undefined for this name.
        @usableFromInline
        internal let _elf: StaticString?

        /// The PE section identifier, or `nil` if undefined for this name.
        @usableFromInline
        internal let _pe: StaticString?

        @inlinable
        internal init(
            machO: (segment: StaticString, section: StaticString)? = nil,
            elf: StaticString? = nil,
            pe: StaticString? = nil
        ) {
            self._machO = machO
            self._elf = elf
            self._pe = pe
        }
    }
}

// MARK: - Well-Known Sections

extension Loader.Section.Name {
    /// Swift test content section.
    ///
    /// Contains test content records registered by the `@Test` macro.
    ///
    /// | Platform | Location |
    /// |----------|----------|
    /// | Darwin   | `__DATA_CONST,__swift5_tests` |
    /// | Linux    | `swift5_tests` |
    /// | Windows  | `.sw5test$B` |
    public static var swiftTestContent: Self {
        Self(
            machO: (segment: "__DATA_CONST", section: "__swift5_tests"),
            elf: "swift5_tests",
            pe: ".sw5test$B"
        )
    }

    /// Fallback test content section for older Darwin binaries.
    ///
    /// Some older binaries use `__DATA` instead of `__DATA_CONST`.
    /// This is Darwin-specific, so only the Mach-O representation is defined.
    public static var swiftTestContentFallback: Self {
        Self(machO: (segment: "__DATA", section: "__swift5_tests"))
    }

    /// Swift type metadata section.
    ///
    /// Contains type metadata records for all Swift types.
    ///
    /// | Platform | Location |
    /// |----------|----------|
    /// | Darwin   | `__TEXT,__swift5_types` |
    /// | Linux    | `swift5_type_metadata` |
    /// | Windows  | `.sw5tymd` |
    public static var swiftTypeMetadata: Self {
        Self(
            machO: (segment: "__TEXT", section: "__swift5_types"),
            elf: "swift5_type_metadata",
            pe: ".sw5tymd"
        )
    }
}

// MARK: - Per-Format Accessors

extension Loader.Section.Name {
    /// The Mach-O segment and section, or `nil` if no Mach-O identifier is defined.
    ///
    /// Read by Darwin platform packages to locate the section in a Mach-O image.
    @inlinable
    public var machO: (segment: StaticString, section: StaticString)? {
        _machO
    }

    /// The ELF section name, or `nil` if no ELF identifier is defined.
    ///
    /// Read by Linux platform packages to locate the section in an ELF image.
    @inlinable
    public var elf: StaticString? {
        _elf
    }

    /// The PE section name, or `nil` if no PE identifier is defined.
    ///
    /// Read by Windows platform packages to locate the section in a PE image.
    @inlinable
    public var pe: StaticString? {
        _pe
    }
}

// MARK: - Equatable/Hashable over StaticString

extension Loader.Section.Name {
    /// Returns a Boolean value indicating whether two names identify the same section.
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        _same(lhs._machO?.segment, rhs._machO?.segment)
            && _same(lhs._machO?.section, rhs._machO?.section)
            && _same(lhs._elf, rhs._elf)
            && _same(lhs._pe, rhs._pe)
    }

    /// Hashes the essential components of this name into the given hasher.
    @inlinable
    public func hash(into hasher: inout Hasher) {
        if let machO = _machO {
            hasher.combine(unsafe Int(bitPattern: machO.segment.utf8Start))
            hasher.combine(unsafe Int(bitPattern: machO.section.utf8Start))
        }
        if let elf = _elf {
            hasher.combine(unsafe Int(bitPattern: elf.utf8Start))
        }
        if let pe = _pe {
            hasher.combine(unsafe Int(bitPattern: pe.utf8Start))
        }
    }

    /// Compares two optional `StaticString` identifiers by their UTF-8 storage address.
    @usableFromInline
    internal static func _same(_ lhs: StaticString?, _ rhs: StaticString?) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil):
            return true

        case (let lhs?, let rhs?):
            return unsafe lhs.utf8Start == rhs.utf8Start

        default:
            return false
        }
    }
}
