//
//  InteractionStateModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/3/2026.
//

import BasePrimitives
/// Bundles up the neccessary parts for callers to initialise state
/// outside of CanvasView. This should be placed as high up the
/// hierarchy as is needed for access.
import SwiftUI

struct InteractionStateModifier: ViewModifier {
  @Environment(\.modifierKeys) private var modifierKeys
  @State private var interactionState: CanvasInteractionState
  @Binding var toolHandler: ToolHandler
  init(
    state: CanvasInteractionState? = nil,
    toolHandler: Binding<ToolHandler>
  ) {
    self._interactionState = State(initialValue: state ?? .init())
    self._toolHandler = toolHandler
  }

  func body(content: Content) -> some View {
    content
      .environment(interactionState)
      .environment(\.zoomLevel, interactionState.zoom)
      .environment(\.panOffset, interactionState.pan)
      .environment(\.rotation, interactionState.rotation)
      .environment(\.pointerLocation, interactionState.pointer.hover.value?.cgPoint)
      .environment(\.canvasOperation, operation)
      .environment(\.canvasInputPolicy, canvasPolicy)

      .task(id: modifierKeys) { toolHandler.updateModifiers(modifierKeys) }
  }
}

extension InteractionStateModifier {
  private var canvasPolicy: CanvasInputPolicy {
    .init(fromOperation: operation, tool: toolHandler.effectiveTool)
  }
  /// The semantic operation currently being performed, computed from all input layers.
  private var operation: CanvasOperation {
    //  private func activeOperation(
    //    state: CanvasInteractionState,
    //    modifiers: Modifiers
    //  ) -> CanvasOperation {
    OperationResolver.resolve(
      state: interactionState,
      activeTool: toolHandler.effectiveTool,
      springLoadedTool: toolHandler.springLoadedTool,
      modifiers: modifierKeys
    )
  }

}
extension View {
  public func setUpInteractionState(
    _ state: CanvasInteractionState? = nil,
    toolHandler: Binding<ToolHandler>,
  ) -> some View {
    self.modifier(
      InteractionStateModifier(
        state: state,
        toolHandler: toolHandler
      )
    )
  }
}
