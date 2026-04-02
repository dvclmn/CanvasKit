//
//  InteractionStateModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/3/2026.
//

import SwiftUI
import GeometryPrimitives

/// Bundles up the necessary parts for callers to initialise state
/// outside of CanvasView. This should be placed as high up the
/// hierarchy as is needed for access.
struct InteractionStateSetupModifier: ViewModifier {
  @Environment(\.modifierKeys) private var modifierKeys
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
      .task(id: toolHandler.toolKind) {
        interactionState.updateTool(to: toolHandler.effectiveTool)
      }
  }
}

extension InteractionStateSetupModifier {
  private var snapshot: CanvasSnapshot? { interactionState.snapshot(canvasSize: canvasSize) }
}

//extension View {
//
//  public func setUpInteractionState(
//    _ state: CanvasInteractionState? = nil,
//    toolHandler: Binding<ToolHandler>,
//  ) -> some View {
//    self.modifier(
//      InteractionStateSetupModifier(
//        state: state,
//        toolHandler: toolHandler,
//      )
//    )
//  }
//}
