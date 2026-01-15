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
    /// Platform-specific section identifiers are provided by the internal
    /// representation. Use well-known constants like `.swiftTestContent`
    /// for portable code.
    ///
    /// ## Platform Representation
    ///
    /// | Platform | Representation |
    /// |----------|---------------|
    /// | Darwin   | Segment + Section (e.g., `__DATA_CONST`, `__swift5_tests`) |
    /// | Linux    | Section name (e.g., `swift5_tests`) |
    /// | Windows  | Section name (e.g., `.sw5test$B`) |
    public struct Name: Sendable, Equatable, Hashable {
        /// Internal representation - opaque to callers.
        @usableFromInline
        internal let _representation: Representation

        @usableFromInline
        internal enum Representation: Sendable, Equatable, Hashable {
            case machO(segment: StaticString, section: StaticString)
            case elf(section: StaticString)
            case pe(section: StaticString)
        }

        @inlinable
        internal init(_representation: Representation) {
            self._representation = _representation
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
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
        return Self(_representation: .machO(segment: "__DATA_CONST", section: "__swift5_tests"))
        #elseif os(Linux) || os(FreeBSD) || os(OpenBSD) || os(Android)
        return Self(_representation: .elf(section: "swift5_tests"))
        #elseif os(Windows)
        return Self(_representation: .pe(section: ".sw5test$B"))
        #else
        return Self(_representation: .elf(section: "swift5_tests"))
        #endif
    }

    /// Fallback test content section for older Darwin binaries.
    ///
    /// Some older binaries use `__DATA` instead of `__DATA_CONST`.
    /// This is Darwin-specific and should only be used as a fallback.
    public static var swiftTestContentFallback: Self {
        Self(_representation: .machO(segment: "__DATA", section: "__swift5_tests"))
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
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
        return Self(_representation: .machO(segment: "__TEXT", section: "__swift5_types"))
        #elseif os(Linux) || os(FreeBSD) || os(OpenBSD) || os(Android)
        return Self(_representation: .elf(section: "swift5_type_metadata"))
        #elseif os(Windows)
        return Self(_representation: .pe(section: ".sw5tymd"))
        #else
        return Self(_representation: .elf(section: "swift5_type_metadata"))
        #endif
    }
}

// MARK: - Platform-Specific Accessors

extension Loader.Section.Name {
    /// For Darwin: extracts segment and section names.
    ///
    /// - Returns: Tuple of segment and section names, or `nil` if this
    ///   is not a Mach-O section name.
    @inlinable
    public var machO: (segment: StaticString, section: StaticString)? {
        guard case .machO(let seg, let sect) = _representation else { return nil }
        return (seg, sect)
    }

    /// For Linux/ELF: extracts section name.
    ///
    /// - Returns: The section name, or `nil` if this is not an ELF section name.
    @inlinable
    public var elf: StaticString? {
        guard case .elf(let sect) = _representation else { return nil }
        return sect
    }

    /// For Windows/PE: extracts section name.
    ///
    /// - Returns: The section name, or `nil` if this is not a PE section name.
    @inlinable
    public var pe: StaticString? {
        guard case .pe(let sect) = _representation else { return nil }
        return sect
    }
}

// MARK: - Equatable/Hashable for StaticString

extension Loader.Section.Name.Representation {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.machO(lSeg, lSect), .machO(rSeg, rSect)):
            return unsafe lSeg.utf8Start == rSeg.utf8Start && lSect.utf8Start == rSect.utf8Start
        case let (.elf(lSect), .elf(rSect)):
            return unsafe lSect.utf8Start == rSect.utf8Start
        case let (.pe(lSect), .pe(rSect)):
            return unsafe lSect.utf8Start == rSect.utf8Start
        default:
            return false
        }
    }

    @inlinable
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .machO(seg, sect):
            hasher.combine(0)
            hasher.combine(unsafe Int(bitPattern: seg.utf8Start))
            hasher.combine(unsafe Int(bitPattern: sect.utf8Start))
        case let .elf(sect):
            hasher.combine(1)
            hasher.combine(unsafe Int(bitPattern: sect.utf8Start))
        case let .pe(sect):
            hasher.combine(2)
            hasher.combine(unsafe Int(bitPattern: sect.utf8Start))
        }
    }
}
