//
//  InteractionStateModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/3/2026.
//

import BasePrimitives
import SwiftUI

/// Bundles up the necessary parts for callers to initialise state
/// outside of CanvasView. This should be placed as high up the
/// hierarchy as is needed for access.
struct InteractionStateSetupModifier: ViewModifier {
  @Environment(\.modifierKeys) private var modifierKeys
  @Environment(\.canvasGeometry) private var canvasGeometry
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

    let snapshot = interactionState.snapshot
    let tool = toolHandler.effectiveTool
    let policy = tool.inputPolicy

    content
      .environment(interactionState)
      .environment(\.canvasInputPolicy, policy)
      .environment(\.zoomLevel, snapshot?.zoom.toDouble ?? 1.0)
      .environment(\.panOffset, snapshot?.pan ?? .zero)
      .environment(\.rotation, snapshot?.rotation ?? .zero)
      .environment(\.pointerLocation, snapshot?.pointerLocation?.cgPoint)
      .environment(\.pointerStyle, interactionState.pointerStyle)
      .environment(\.activeTool, toolHandler.effectiveTool)

      .task(id: modifierKeys) {
        toolHandler.updateModifiers(modifierKeys)
        interactionState.updateModifiers(modifierKeys)
      }
      .task(id: toolHandler.toolKind) {
        interactionState.activeTool = toolHandler.effectiveTool
      }

      .task(id: canvasGeometry) { interactionState.geometry = canvasGeometry }
  }
}

extension View {
  public func setUpInteractionState(
    _ state: CanvasInteractionState? = nil,
    toolHandler: Binding<ToolHandler>
  ) -> some View {
    self.modifier(
      InteractionStateSetupModifier(
        state: state,
        toolHandler: toolHandler
      )
    )
  }
}
