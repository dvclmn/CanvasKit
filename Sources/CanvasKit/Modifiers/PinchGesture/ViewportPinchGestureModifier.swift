//
//  ViewportPinchGestureModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 30/7/2026.
//

import SwiftUI

private struct ViewportPinchGestureModifier: ViewModifier {
  @State private var eventAccumulator = ViewportPinchEventAccumulator()

  let isEnabled: Bool
  let action: ViewportPinchOutput

  func body(content: Content) -> some View {
    content
      .gesture(magnifyGesture, isEnabled: isEnabled)
      .onChange(of: isEnabled) { _, isEnabled in
        if !isEnabled {
          eventAccumulator.reset()
        }
      }
  }

  private var magnifyGesture: some Gesture {
    MagnifyGesture(minimumScaleDelta: 0.01)
      .onChanged { value in
        guard let event = eventAccumulator.changed(
          magnification: value.magnification
        ) else {
          return
        }

        action(event)
      }
      .onEnded { value in
        guard let event = eventAccumulator.ended(
          magnification: value.magnification
        ) else {
          return
        }

        action(event)
      }
  }
}

extension View {

  /// Responds to pinch magnification as neutral viewport input.
  ///
  /// Use this modifier when the consumer, rather than CanvasKit, owns the
  /// response policy. For standard viewport zoom, use `onPinchGesture` instead.
  public func onViewportPinch(
    isEnabled: Bool = true,
    perform action: @escaping ViewportPinchOutput,
  ) -> some View {
    modifier(
      ViewportPinchGestureModifier(
        isEnabled: isEnabled,
        action: action,
      )
    )
  }
}
