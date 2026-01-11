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

extension Loader {
    /// Section enumeration interface.
    ///
    /// Provides access to reading data from specific sections within loaded
    /// executable images. This enables runtime discovery of metadata stored
    /// in designated binary sections (e.g., Swift test content, type metadata).
    ///
    /// ## Design
    ///
    /// The Section domain is organized into:
    /// - `Loader.Section.Name` - section identifier (platform-specific)
    /// - `Loader.Section.Bounds` - memory bounds of a discovered section
    ///
    /// Platform implementations live in:
    /// - `Darwin.Loader.Section` - Mach-O getsectiondata/dyld APIs
    /// - `Linux.Loader.Section` - ELF swift_enumerateAllMetadataSections
    /// - `Windows.Loader.Section` - PE section enumeration (future)
    ///
    /// ## Thread Safety
    ///
    /// Section enumeration is thread-safe. The returned bounds are valid
    /// for the lifetime of the loaded image. However, images can be unloaded
    /// dynamically, invalidating any section pointers.
    public enum Section: Sendable {}
}
