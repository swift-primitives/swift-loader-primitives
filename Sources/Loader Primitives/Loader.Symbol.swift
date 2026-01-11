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
    /// Symbol lookup interface.
    ///
    /// Provides the ability to look up symbols (functions, data) in loaded
    /// dynamic libraries or the current process image.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Look up a symbol in all loaded libraries
    /// let sym = try Loader.Symbol.lookup(name: "myFunction", in: .default)
    ///
    /// // Cast to appropriate function type
    /// typealias MyFunc = @convention(c) () -> Int32
    /// let func = unsafeBitCast(sym, to: MyFunc.self)
    /// ```
    ///
    /// ## Pointer Lifetime
    ///
    /// - Returned `UnsafeRawPointer` is valid only while the owning library remains loaded
    /// - Caller is responsible for correct casting and calling convention
    /// - `UnsafeRawPointer` is NOT a function pointer; cast must respect platform ABI
    public enum Symbol: Sendable {}
}
