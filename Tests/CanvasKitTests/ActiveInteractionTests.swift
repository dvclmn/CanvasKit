//
//  ActiveInteractionTests.swift
//  CanvasKit
//
//  Created by Dave Coleman on 30/6/2026.
//

import Observation
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
    #expect(handler.canvasInteractionActivity.contains(.pinch))

    _ = handler.processInteraction(
      .pinch(scale: 1.0),
      phase: .ended,
      modifiers: [],
    )

    #expect(!handler.activeInteraction.contains(.pinch))
    #expect(handler.latestInteraction.phase(for: .pinch) == .ended)
    #expect(handler.canvasInteractionActivity == .none)
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
    #expect(handler.canvasInteractionActivity.activeKinds == [.pinch, .hover])

    handler.endInteraction(
      .hover,
      phase: .ended,
      modifiers: [],
    )

    #expect(handler.activeInteraction.contains(.pinch))
    #expect(!handler.activeInteraction.contains(.hover))
    #expect(handler.latestInteraction.phase(for: .hover) == .ended)
    #expect(handler.canvasInteractionActivity.activeKinds == [.pinch])
  }

  @Test func activeContextUpdatesDoNotRepublishUnchangedCanvasActivity() {
    let handler = CanvasHandler(toolConfiguration: nil)

    _ = handler.processInteraction(
      .swipe(delta: .init(width: 4, height: 6)),
      phase: .began,
      modifiers: [],
    )

    #expect(handler.canvasInteractionActivity.isSwipeActive)

    var observedChanges = 0
    withObservationTracking {
      _ = handler.canvasInteractionActivity
    } onChange: {
      observedChanges += 1
    }

    _ = handler.processInteraction(
      .swipe(delta: .init(width: 8, height: 10)),
      phase: .changed,
      modifiers: [],
    )

    #expect(observedChanges == 0)

    _ = handler.processInteraction(
      .swipe(delta: .zero),
      phase: .ended,
      modifiers: [],
    )

    #expect(observedChanges == 1)
    #expect(handler.canvasInteractionActivity == .none)
  }
}
