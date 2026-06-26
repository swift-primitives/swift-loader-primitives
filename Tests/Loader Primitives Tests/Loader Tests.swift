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
