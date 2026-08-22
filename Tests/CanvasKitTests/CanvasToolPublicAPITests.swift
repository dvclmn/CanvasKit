//
//  CanvasToolPublicAPITests.swift
//  CanvasKit
//
//  Created by Dave Coleman on 2/5/2026.
//

import CanvasKit
import SwiftUI
import Testing

struct CanvasToolPublicAPITests {

  @Test func appDefinedToolCanInspectInteractionContext() {
    let tool = PublicTool()
    let context = InteractionContext(
      interaction: .pinch(scale: 1.2),
      phase: .changed,
      modifiers: [.option],
    )

    #expect(context.interaction.kind == .pinch)
    #expect(context.phase == .changed)
    #expect(context.modifiers.contains(.option))
    #expect(context.matchedCapability == nil)
    #expect(context.intent == nil)
    _ = tool.resolveInteraction(context: context, currentTransform: .identity)
  }

  @Test func consumedIsAvailableWithoutExposingInternalState() {
    let resolution = ToolResolution.consumed

    switch resolution {
      case .handled(.none):
        break
      default:
        Issue.record("Expected consumed to represent a handled no-op")
    }
  }
}

private struct PublicTool: CanvasTool {
  let id: CanvasToolID = "public-tool"
  let name = "Public Tool"
  let icon = "hammer"

  var dragConfiguration: PointerDragConfiguration { .continuous }
  var inputCapabilities: [ToolCapability] {
    [
      ToolCapability(interaction: .drag, intent: .pan),
      ToolCapability(interaction: .pinch, intent: .zoom),
    ]
  }

  func resolvePointerStyle(context: InteractionContext) -> CanvasPointerStyle {
    context.isPointerDragging ? .grabActive : .default
  }

  func resolveInteraction(
    context: InteractionContext,
    currentTransform: TransformState,
  ) -> ToolResolution {
    switch context.interaction {
      case .pinch:
        return .consumed
      default:
        return .passthrough
    }
  }
}
