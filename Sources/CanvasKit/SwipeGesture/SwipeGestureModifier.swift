//
//  TestPanGestureModifier.swift
//  Paperbark
//
//  Created by Dave Coleman on 24/6/2025.
//

import SwiftUI
import BasePrimitives

struct SwipeGestureModifier: ViewModifier {

  @State private var modifiers: Modifiers = []

  let isEnabled: Bool
  let action: (SwipeEvent) -> Void

  func body(content: Content) -> some View {
    content
      .overlay {
        if isEnabled {
          SwipeGestureView { event, modifiers in
            self.modifiers = modifiers
            action(event)
          }
          /// This adds the modifiers to the Environment. This is also done separately
          /// by `InteractionKit/ModifierKeysModifier`, but thankfully
          /// they don't seem to clash.
          ///
          /// In this case, the modifiers come from the NSEvent via `scrollWheel(with:)`
          /// in `SwipeTrackingNSView`, as this gesture, when active, seems to
          /// block/override reading of modifiers in `ModifierKeysModifier`
          .environment(\.modifierKeys, modifiers)
        }
      }
  }
}
extension View {
  /// Typically used for Pan, but useful for other swipe-y things too.
  public func onSwipeGesture(
    isEnabled: Bool = true,
    perform action: @escaping (SwipeEvent) -> Void,
  ) -> some View {
    self.modifier(
      SwipeGestureModifier(
        isEnabled: isEnabled,
        action: action,
      )
    )
  }
}
