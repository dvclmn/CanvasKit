//
//  ToolConfigurationTests.swift
//  CanvasKit
//
//  Created by Dave Coleman on 31/8/2026.
//

import Testing

@testable import CanvasKit

struct ToolConfigurationTests {

  @Test func defaultsRegisteringToolsPreservesDefaultsAndReplacesMatchingTool() throws {
    let configuration = ToolConfiguration.defaults(
      registering: [SelectTool(showsMarquee: false)],
    )

    #expect(configuration.tools.map(\.id) == [.select, .pan, .zoom])
    #expect(configuration.bindings == ToolConfiguration.default.bindings)
    #expect(configuration.springLoadDelay == ToolConfiguration.default.springLoadDelay)

    let selectTool = try #require(configuration.registeredTool(for: .select) as? SelectTool)
    #expect(!selectTool.showsMarquee)
  }
}
