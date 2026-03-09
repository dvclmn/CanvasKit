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

struct InteractionStateModifier: ViewModifier {
  @State private var interactionState: InteractionState

  init(
    state: InteractionState? = nil,
  ) {
    self._interactionState = State(initialValue: state ?? .init())
  }

  func body(content: Content) -> some View {
    content
      .environment(interactionState)
      .environment(\.zoomLevel, interactionState.transform.zoom)
      .environment(\.panOffset, interactionState.transform.pan)
      .environment(\.rotation, interactionState.transform.rotation)
      .environment(\.pointerLocation, interactionState.pointer.pointerHover.value)
  }
}
extension View {
  public func setUpInteractionState(_ state: InteractionState? = nil) -> some View {
    self.modifier(InteractionStateModifier(state: state))
  }
}
