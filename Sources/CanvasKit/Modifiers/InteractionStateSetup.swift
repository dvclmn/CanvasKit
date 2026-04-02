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
//  @Environment(\.zoomRange) private var zoomRange
  @State private var interactionState: CanvasInteractionState = .init()

  @Binding var toolHandler: ToolHandler
  let canvasSize: Size<CanvasSpace>

  func body(content: Content) -> some View {
    content
      .environment(interactionState)

      .setSnapshotValues(
        interactionState.snapshot(in: canvasSize)
      )

      .environment(\.pointerStyle, interactionState.pointerStyle)

      .task(id: modifierKeys) {
        toolHandler.updateModifiers(modifierKeys)
      }
    
    // MARK: -
      .environment(\.activeTool, toolHandler.effectiveTool)
      .syncEnvironment(\.activeTool, to: $interactionState.activeTool)
      /// Watches tool kind rather than the tool itself, as `any CanvasTool`
      /// can't conform to Equatable
//      .task(id: toolHandler.effectiveTool.kind) {
//        interactionState.updateTool(to: toolHandler.effectiveTool)
//      }
    

      /// Provides interaction state with updated zoom range
//      .task(id: zoomRange) {
//        interactionState.zoomRange = zoomRange
//      }
      .syncEnvironment(\.zoomRange, to: $interactionState.zoomRange)
  }
}
