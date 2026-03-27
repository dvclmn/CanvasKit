//
//  TestPanGestureModifier.swift
//  Paperbark
//
//  Created by Dave Coleman on 24/6/2025.
//

import SwiftUI

#if canImport(AppKit)

public struct SwipeGestureModifier: ViewModifier {

  @State private var modifiers: Modifiers = []

  let isEnabled: Bool
  let onSwipeGesture: SwipeOutput

  public func body(content: Content) -> some View {
    content
      .overlay {
        if isEnabled {
          SwipeGestureView { event, modifiers in
            self.modifiers = modifiers
            onSwipeGesture(event)
          }
          //          SwipeGestureView(onSwipeGesture)
          //          .environment(\.modifierKeys, [])
          .environment(\.modifierKeys, modifiers)
        }

      }
  }
}
extension View {
  /// Aka pan gesture
  public func onSwipeGesture(
    isEnabled: Bool = true,
    _ onSwipeGesture: @escaping SwipeOutput
  ) -> some View {
    self.modifier(
      SwipeGestureModifier(
        isEnabled: isEnabled,
        onSwipeGesture: onSwipeGesture
      )
    )
  }
}
#endif
