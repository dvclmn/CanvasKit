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
    let policy = interactionState.activeTool.inputPolicy

    content
      .environment(interactionState)
      .environment(\.canvasInputPolicy, policy)
      .environment(\.zoomLevel, snapshot?.zoom.toDouble ?? 1.0)
      .environment(\.panOffset, snapshot?.pan ?? .zero)
      .environment(\.rotation, snapshot?.rotation ?? .zero)
      .environment(\.pointerLocation, snapshot?.pointerLocation?.cgPoint)
      .task(id: modifierKeys) { toolHandler.updateModifiers(modifierKeys) }
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
