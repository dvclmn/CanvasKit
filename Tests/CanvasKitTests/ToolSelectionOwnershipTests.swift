//
//  ToolSelectionOwnershipTests.swift
//  CanvasKit
//
//  Created by Dave Coleman on 20/8/2026.
//

import SwiftUI
import Testing

@testable import CanvasKit

struct ToolSelectionOwnershipTests {

  @Test func externalSelectionSeedsCommittedTool() {
    let handler = CanvasHandler(
      toolConfiguration: .default,
      toolSelection: .init(id: .zoom),
    )

    #expect(handler.committedToolSelection.committedToolID == .zoom)
    #expect(handler.toolHandler.committedToolID == .zoom)
    #expect(handler.toolHandler.effectiveToolID == .zoom)
  }

  @Test func invalidExternalSelectionNormalisesToConfigurationDefault() {
    let configuration = ToolConfiguration(
      tools: [PanTool(), SelectTool()],
      bindings: [],
    )
    let handler = CanvasHandler(
      toolConfiguration: configuration,
      toolSelection: .init(id: "missing"),
    )

    #expect(handler.committedToolSelection.committedToolID == .pan)
  }

  @Test func canvasCommitUpdatesTheSynchronisedSelectionValue() {
    let handler = CanvasHandler(
      toolConfiguration: .default,
      toolSelection: .init(id: .select),
    )

    handler.toolHandler.setCommittedTool(id: .pan)

    #expect(handler.committedToolSelection.committedToolID == .pan)
  }

  @Test func parentChangeUpdatesCommittedAndEffectiveTool() {
    let handler = CanvasHandler(
      toolConfiguration: .default,
      toolSelection: .init(id: .select),
    )

    handler.committedToolSelection = .init(id: .zoom)

    #expect(handler.toolHandler.committedToolID == .zoom)
    #expect(handler.toolHandler.effectiveToolID == .zoom)
  }

  @Test func invalidParentChangeRepairsCommittedSelection() {
    let handler = CanvasHandler(
      toolConfiguration: .default,
      toolSelection: .init(id: .zoom),
    )

    handler.committedToolSelection = .init(id: "missing")

    #expect(handler.committedToolSelection.committedToolID == .select)
    #expect(handler.toolHandler.effectiveToolID == .select)
  }

  @Test func transientOverrideNeverRewritesCommittedSelection() {
    let handler = CanvasHandler(
      toolConfiguration: .default,
      toolSelection: .init(id: .select),
    )

    handler.toolHandler.handleKeyDown(.space)

    #expect(handler.toolHandler.effectiveToolID == .pan)
    #expect(handler.committedToolSelection.committedToolID == .select)

    handler.toolHandler.handleKeyUp(.space)

    #expect(handler.toolHandler.effectiveToolID == .select)
    #expect(handler.committedToolSelection.committedToolID == .select)
  }

  @Test func parentChangeDuringOverrideIsRevealedOnRelease() {
    let handler = CanvasHandler(
      toolConfiguration: .default,
      toolSelection: .init(id: .select),
    )

    handler.toolHandler.handleKeyDown(.space)
    handler.committedToolSelection = .init(id: .zoom)

    #expect(handler.committedToolSelection.committedToolID == .zoom)
    #expect(handler.toolHandler.effectiveToolID == .pan)

    handler.toolHandler.handleKeyUp(.space)

    #expect(handler.toolHandler.effectiveToolID == .zoom)
    #expect(handler.committedToolSelection.committedToolID == .zoom)
  }
}
