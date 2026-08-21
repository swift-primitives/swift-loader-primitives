extension Loader.Section {

    public struct Name: Sendable, Equatable, Hashable {

        @usableFromInline
        internal let _machO: (segment: StaticString, section: StaticString)?

        @usableFromInline
        internal let _elf: StaticString?

        @usableFromInline
        internal let _pe: StaticString?

        @inlinable
        package init(
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

extension Loader.Section.Name {

    public static var swiftTestContent: Self {
        Self(
            machO: (segment: "__DATA_CONST", section: "__swift5_tests"),
            elf: "swift5_tests",
            pe: ".sw5test$B"
        )
    }

    public static var swiftTestContentFallback: Self {
        Self(machO: (segment: "__DATA", section: "__swift5_tests"))
    }

    public static var swiftTypeMetadata: Self {
        Self(
            machO: (segment: "__TEXT", section: "__swift5_types"),
            elf: "swift5_type_metadata",
            pe: ".sw5tymd"
        )
    }
}

extension Loader.Section.Name {

    @inlinable
    public var machO: (segment: StaticString, section: StaticString)? {
        _machO
    }

    @inlinable
    public var elf: StaticString? {
        _elf
    }

    @inlinable
    public var pe: StaticString? {
        _pe
    }
}

extension Loader.Section.Name {

    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        _same(lhs._machO?.segment, rhs._machO?.segment)
            && _same(lhs._machO?.section, rhs._machO?.section)
            && _same(lhs._elf, rhs._elf)
            && _same(lhs._pe, rhs._pe)
    }

    @inlinable
    public func hash(into hasher: inout Hasher) {
        if let machO = _machO {
            Self._hash(machO.segment, into: &hasher)
            Self._hash(machO.section, into: &hasher)
        }
        if let elf = _elf {
            Self._hash(elf, into: &hasher)
        }
        if let pe = _pe {
            Self._hash(pe, into: &hasher)
        }
    }

    @usableFromInline
    internal static func _hash(_ string: StaticString, into hasher: inout Hasher) {
        string.withUTF8Buffer { bytes in
            unsafe hasher.combine(bytes: UnsafeRawBufferPointer(bytes))
        }
    }

    @usableFromInline
    internal static func _same(_ lhs: StaticString?, _ rhs: StaticString?) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil):
            return true

        case (let lhs?, let rhs?):
            return lhs.withUTF8Buffer { lhsBytes in
                rhs.withUTF8Buffer { rhsBytes in
                    unsafe lhsBytes.elementsEqual(rhsBytes)
                }
            }

        default:
            return false
        }
    }
}
