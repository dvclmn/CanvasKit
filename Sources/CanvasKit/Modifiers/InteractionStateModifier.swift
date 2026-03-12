//
//  InteractionStateModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/3/2026.
//

/// Bundles up the neccessary parts for callers to initialise state
/// outside of CanvasView. This should be placed as high up the
/// hierarchy as is needed for access.
import SwiftUI
import BasePrimitives

struct InteractionStateModifier: ViewModifier {
  @State private var interactionState: CanvasInteraction

  init(
    state: CanvasInteraction? = nil,
  ) {
    self._interactionState = State(initialValue: state ?? .init())
  }

  func body(content: Content) -> some View {
    content
      .environment(interactionState)
      .environment(\.zoomLevel, interactionState.zoom)
      .environment(\.panOffset, interactionState.pan)
      .environment(\.rotation, interactionState.rotation)
      .environment(\.pointerLocation, interactionState.pointer.hover.value)
  }
}
extension View {
  public func setUpInteractionState(_ state: CanvasInteraction? = nil) -> some View {
    self.modifier(InteractionStateModifier(state: state))
  }
}
