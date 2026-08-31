//
//  PointerDragConfigurationTests.swift
//  CanvasKit
//
//  Created by Dave Coleman on 31/8/2026.
//

import Testing
@testable import CanvasKit

@Suite
struct PointerDragConfigurationTests {

  @Test func hiddenSelectMarqueePreservesSelectionDragSemantics() throws {
    let tool = SelectTool(showsMarquee: false)
    let dragCapability = try #require(
      tool.inputCapabilities.first { $0.interactionKind == .drag }
    )

    #expect(tool.dragConfiguration.behaviour == .marquee)
    #expect(tool.dragConfiguration.showsMarquee == false)
    #expect(dragCapability.intent == .select)
  }

  @Test func continuousDragDoesNotExposeMarqueePresentation() {
    let configuration = PointerDragConfiguration(
      behaviour: .continuous(),
      showsMarquee: true,
    )

    #expect(configuration.showsMarquee == false)
  }
}
