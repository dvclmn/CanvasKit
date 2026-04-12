//
//  TestPanGestureModifier.swift
//  Paperbark
//
//  Created by Dave Coleman on 24/6/2025.
//

import BasePrimitives
import SwiftUI

struct SwipeGestureModifier: ViewModifier {

  /// My usual approach for modifiers is that they are captured higher up the
  /// hierarchy, and available in the environment. However the way swipe
  /// (scrollwheel) events are captured for this modifier (see `SwipeTrackingNSView`)
  /// disrupts that process, so any modifiers detected during the swipe events are
  /// held here and added to the Environment.
  @State private var modifiers: Modifiers = []

  let isEnabled: Bool
  let action: SwipeOutput

  func body(content: Content) -> some View {
    content
      .overlay {
        if isEnabled {
          SwipeGestureView { event in
            self.modifiers = event.modifiers
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
    perform action: @escaping SwipeOutput
  ) -> some View {
    self.modifier(
      SwipeGestureModifier(
        isEnabled: isEnabled,
        action: action,
      )
    )
  }
}
