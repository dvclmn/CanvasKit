//
//  InteractionStateModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/3/2026.
//

import GeometryPrimitives
import SwiftUI

/// Bundles up the necessary parts for callers to initialise state
/// outside of CanvasView. This should be placed as high up the
/// hierarchy as is needed for access.
struct InteractionStateSetupModifier: ViewModifier {
  @Environment(\.modifierKeys) private var modifierKeys
  @Environment(\.zoomRange) private var zoomRange
  @State private var interactionState: CanvasInteractionState = .init()

  @Binding var toolHandler: ToolHandler
  let canvasSize: Size<CanvasSpace>

  //  init(
  //    state: CanvasInteractionState? = nil,
  //    toolHandler: Binding<ToolHandler>,
  //    canvasSize: Size<CanvasSpace>,
  //  ) {
  //    self._interactionState = State(initialValue: state ?? .init())
  //    self._toolHandler = toolHandler
  //    self.canvasSize = canvasSize
  //  }

  func body(content: Content) -> some View {
    content
      .environment(interactionState)
      .setSnapshotValues(snapshot)

      .environment(\.pointerStyle, interactionState.pointerStyle)
      .environment(\.activeTool, toolHandler.effectiveTool)

      .task(id: modifierKeys) {
        toolHandler.updateModifiers(modifierKeys)
      }

      /// Watches tool kind rather than the tool itself, as `any CanvasTool`
      /// can't conform to Equatable
      .task(id: toolHandler.effectiveTool.kind) {
        interactionState.updateTool(to: toolHandler.effectiveTool)
      }
      /// Provides interaction state with updated zoom range
      .task(id: zoomRange) {
        interactionState.zoomRange = zoomRange
      }

  }
}

extension InteractionStateSetupModifier {
  private var snapshot: CanvasSnapshot? { interactionState.snapshot(canvasSize: canvasSize) }
}
