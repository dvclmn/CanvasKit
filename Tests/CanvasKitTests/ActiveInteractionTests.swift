//
//  ActiveInteractionTests.swift
//  CanvasKit
//
//  Created by Dave Coleman on 30/6/2026.
//

import Testing

@testable import CanvasKit

struct ActiveInteractionTests {

  @Test func terminalPhaseClearsActiveInteraction() {
    let handler = CanvasHandler(toolConfiguration: nil)

    _ = handler.processInteraction(
      .pinch(scale: 1.2),
      phase: .began,
      modifiers: [],
    )

    #expect(handler.activeInteraction.contains(.pinch))
    #expect(handler.activeInteraction.phase(for: .pinch) == .began)

    _ = handler.processInteraction(
      .pinch(scale: 1.0),
      phase: .ended,
      modifiers: [],
    )

    #expect(!handler.activeInteraction.contains(.pinch))
    #expect(handler.latestInteraction.phase(for: .pinch) == .ended)
  }

  @Test func endingOneInteractionKindPreservesOtherActiveKinds() {
    let handler = CanvasHandler(toolConfiguration: nil)

    _ = handler.processInteraction(
      .pinch(scale: 1.2),
      phase: .changed,
      modifiers: [],
    )

    _ = handler.processInteraction(
      .hover(.init(x: 20, y: 30)),
      phase: .changed,
      modifiers: [],
    )

    #expect(handler.activeInteraction.contains(.pinch))
    #expect(handler.activeInteraction.contains(.hover))

    handler.endInteraction(
      .hover,
      phase: .ended,
      modifiers: [],
    )

    #expect(handler.activeInteraction.contains(.pinch))
    #expect(!handler.activeInteraction.contains(.hover))
    #expect(handler.latestInteraction.phase(for: .hover) == .ended)
  }
}
