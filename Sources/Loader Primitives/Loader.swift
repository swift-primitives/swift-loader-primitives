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

/// Dynamic loader interface.
///
/// Provides access to dynamic linking and symbol resolution functionality.
/// This is the correct semantic home for `dlopen`/`dlsym` style APIs - these
/// are userspace loader interfaces, NOT kernel syscalls.
///
/// ## Design
///
/// The Loader domain is organized into:
/// - `Loader.Symbol` - symbol lookup by name
/// - `Loader.Library` - dynamic library loading (open/close)
///
/// Platform implementations live in:
/// - `POSIX.Loader` - dlopen/dlsym/dlerror
/// - `Darwin.Loader` - additional dyld APIs (future)
/// - `Windows.Loader` - LoadLibrary/GetProcAddress (future)
///
/// ## Semantic Correctness
///
/// `dlsym`/`dlopen` are NOT syscalls. They are implemented by:
/// - `libSystem.B.dylib` / dyld on Darwin
/// - `libdl.so` / ld.so on Linux
/// - Win32 loader on Windows
///
/// Therefore, these APIs belong in `Loader`, NOT `Kernel`.
public enum Loader: Sendable {}
