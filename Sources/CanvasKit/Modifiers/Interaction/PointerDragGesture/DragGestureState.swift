//
//  DragGestureState.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 14/1/2026.
//

import BasePrimitives
import SwiftUI

/// Internal state machine for ``PointerDragModifier``.
///
/// Handles both ``PointerDragBehaviour/marquee`` and ``PointerDragBehaviour/continuous(_:)`` modes:
///
/// ## Continuous
/// Produces frame-to-frame deltas, the difference in
/// `DragGesture.Value.translation` between successive `onChanged` calls.
///
/// ## Marquee
/// Returns a `.rect` from `startLocation` to `location` using
/// values directly from `DragGesture.Value`. All state is cleared on end.
struct DragGestureState {

  var behaviour: PointerDragBehaviour = .none

  /// For continuous mode: the previous `DragGesture.Value.translation`,
  /// used to compute the frame-to-frame delta. `nil` on first frame.
  private var previousGestureTranslation: CGSize?
}

extension DragGestureState {

  /// Processes a drag gesture value and returns the payload for this frame.
  mutating func update(
    _ gestureValue: DragGesture.Value
  ) -> PointerDragPayload? {

    switch behaviour {
      case .marquee:
        return .rect(
          from: .init(fromPoint: gestureValue.startLocation),
          current: .init(fromPoint: gestureValue.location),
        )

      case .continuous(let axes):
        let prev = previousGestureTranslation ?? .zero
        let rawDelta = CGSize(
          width: gestureValue.translation.width - prev.width,
          height: gestureValue.translation.height - prev.height,
        )
        let constrained = applyAxis(axes, delta: rawDelta)
        previousGestureTranslation = gestureValue.translation

        let size = Size<ScreenSpace>(fromCGSize: constrained)
        let location = Point<ScreenSpace>(fromPoint: gestureValue.location)
        return .delta(size, location: location)

      case .none:
        return nil
    }
  }

  /// Clears per-gesture tracking state. Called from `DragGesture.onEnded`.
  mutating func end() { previousGestureTranslation = nil }

  /// Zeroes out movement on locked axes.
  private func applyAxis(
    _ axes: GeometryAxis.Set,
    delta: CGSize,
  ) -> CGSize {
    switch axes {
      case .horizontal: CGSize(width: delta.width, height: 0)
      case .vertical: CGSize(width: 0, height: delta.height)
      default: delta
    }
  }
}
