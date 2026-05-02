//
//  CanvasToolPublicAPITests.swift
//  CanvasKit
//
//  Created by Dave Coleman on 2/5/2026.
//

import CanvasKit
import GeometryPrimitives
import InputPrimitives
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
    _ = tool.resolveInteraction(context: context, currentTransform: .identity)
  }
}

private struct PublicTool: CanvasTool {
  let kind: CanvasToolKind = "public-tool"
  let name = "Public Tool"
  let icon = "hammer"

  var dragBehaviour: PointerDragBehaviour { .continuous }
  var inputCapabilities: [ToolCapability] {
    [
      ToolCapability(interaction: .drag, intent: .pan),
      ToolCapability(interaction: .pinch, intent: .zoom),
    ]
  }

  func resolvePointerStyle(context: InteractionContext) -> PointerStyleCompatible {
    context.isPointerDragging ? .grabActive : .default
  }

  func resolveInteraction(
    context: InteractionContext,
    currentTransform: TransformState,
  ) -> ToolResolution {
    switch context.interaction {
      case .pinch:
        return .handled(.none)
      default:
        return .passthrough
    }
  }
}
