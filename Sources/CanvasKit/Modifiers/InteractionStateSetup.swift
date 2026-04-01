//
//  InteractionStateModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/3/2026.
//

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
    toolHandler: Binding<ToolHandler>,
  ) {
    self._interactionState = State(initialValue: state ?? .init())
    self._toolHandler = toolHandler
  }

  func body(content: Content) -> some View {
    content
      .environment(interactionState)
//      .environment(\.canvasInputPolicy, toolHandler.effectiveTool.inputPolicy)
      .environment(\.zoomLevel, snapshot.map { Double($0.zoom) } ?? 1.0)
      .environment(\.panOffset, snapshot?.pan ?? .zero)
      .environment(\.rotation, snapshot?.rotation ?? .zero)
      .environment(\.pointerLocation, snapshot?.pointerLocation?.cgPoint)
      .environment(\.pointerStyle, interactionState.pointerStyle(with: modifierKeys))
      .environment(\.activeTool, toolHandler.effectiveTool)

      .task(id: modifierKeys) {
        toolHandler.updateModifiers(modifierKeys)
      }
      .task(id: toolHandler.toolKind) {
        interactionState.updateTool(to: toolHandler.effectiveTool)
        //        interactionState.activeTool = toolHandler.effectiveTool
      }
  }
}

extension InteractionStateSetupModifier {
  private var snapshot: CanvasSnapshot? { interactionState.snapshot }
}

extension View {

  public func setUpInteractionState(
    _ state: CanvasInteractionState? = nil,
    toolHandler: Binding<ToolHandler>,
  ) -> some View {
    self.modifier(
      InteractionStateSetupModifier(
        state: state,
        toolHandler: toolHandler,
      )
    )
  }
}
