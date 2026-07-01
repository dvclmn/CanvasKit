//
//  TestPanGestureModifier.swift
//  Paperbark
//
//  Created by Dave Coleman on 24/6/2025.
//

private import CoreTools
import SwiftUI
private import ViewTools

struct SwipeGestureModifier: ViewModifier {
  let isEnabled: Bool
  let shouldReceive: (SwipeEvent) -> Bool
  let action: SwipeOutput

  func body(content: Content) -> some View {
    content
      .overlay {
        if isEnabled {
          SwipeGestureView { event in
            guard shouldReceive(event) else { return false }
            action(event)
            return true
          }
        }
      }
  }
}
extension View {
  /// Typically used for Pan, but useful for other swipe-y things too.
  func onSwipeGesture(
    isEnabled: Bool = true,
    shouldReceive: @escaping (SwipeEvent) -> Bool = { _ in true },
    perform action: @escaping SwipeOutput,
  ) -> some View {
    self.modifier(
      SwipeGestureModifier(
        isEnabled: isEnabled,
        shouldReceive: shouldReceive,
        action: action,
      )
    )
  }
}

private struct ViewportSwipeModifier: ViewModifier {
  let requiredModifiers: EventModifiers
  let isEnabled: Bool
  let action: SwipeOutput

  func body(content: Content) -> some View {
    content.onSwipeGesture(
      isEnabled: isEnabled,
      shouldReceive: { event in
        event.matches(requiredModifiers: requiredModifiers)
      },
      perform: action,
    )
  }
}

extension View {

  /// Responds to two-finger trackpad swipe events in the view's viewport.
  ///
  /// `requiredModifiers` is matched as a subset, so `.option` also matches
  /// Option-Shift. Events that do not match are passed up the responder chain.
  public func onViewportSwipe(
    requiredModifiers: EventModifiers = [],
    isEnabled: Bool = true,
    perform action: @escaping SwipeOutput,
  ) -> some View {
    self.modifier(
      ViewportSwipeModifier(
        requiredModifiers: requiredModifiers,
        isEnabled: isEnabled,
        action: action,
      )
    )
  }
}
