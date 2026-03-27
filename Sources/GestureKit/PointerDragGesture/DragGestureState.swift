//
//  DragGestureState.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 14/1/2026.
//

import SwiftUI

/// Internal state machine for ``PointerDragModifier``.
///
/// Handles both ``DragBehavior/marquee`` and ``DragBehavior/continuous(_:)`` modes:
///
/// - **Continuous**: Produces **frame-to-frame deltas** — the difference in
///   `DragGesture.Value.translation` between successive `onChanged` calls.
///   This means the modifier never needs to know the current accumulated offset,
///   so external changes (swipe pan, programmatic reset) between drags are
///   transparent. No baseline sync required.
///
/// - **Marquee**: Returns a `.rect` from `startLocation` to `location` using
///   values directly from `DragGesture.Value`. All state is cleared on end.
struct DragGestureState {

  var behaviour: DragBehavior?

  /// For continuous mode: the previous `DragGesture.Value.translation`,
  /// used to compute the frame-to-frame delta. `nil` on first frame.
  private var previousGestureTranslation: CGSize?

}

extension DragGestureState {

  /// Processes a drag gesture value and returns the payload for this frame.
  ///
  /// - **Marquee**: `.rect(from: startLocation, current: location)`.
  ///   Uses `DragGesture.Value.startLocation` which is stable across all
  ///   `onChanged` calls within a single gesture.
  /// - **Continuous**: `.delta(frameDelta, location)` where `frameDelta` is
  ///   `gestureValue.translation - previousTranslation`, axis-constrained.
  /// - **None**: `nil`.
  mutating func update(
    _ gestureValue: DragGesture.Value
  ) -> PointerDragPayload? {
    guard let behaviour else { return nil }
    switch behaviour {
      case .marquee:
        return .rect(
          from: .init(fromPoint: gestureValue.startLocation),
          current: .init(fromPoint: gestureValue.location)
        )

      case .continuous(let axes):
        let prev = previousGestureTranslation ?? .zero
        let rawDelta = CGSize(
          width: gestureValue.translation.width - prev.width,
          height: gestureValue.translation.height - prev.height
        )
        let constrained = applyAxis(axes, delta: rawDelta)
        previousGestureTranslation = gestureValue.translation
        return .delta(
          .init(fromCGSize: constrained),
          location: .init(fromPoint: gestureValue.location)
        )

      case .none:
        return nil
    }
  }

  /// Clears per-gesture tracking state. Call from `DragGesture.onEnded`.
  mutating func end() {
    previousGestureTranslation = nil
  }

  // MARK: - Axis constraint

  /// Zeroes out movement on locked axes.
  private func applyAxis(
    _ axes: GridAxis.Set,
    delta: CGSize
  ) -> CGSize {
    switch axes {
      case .horizontal: CGSize(width: delta.width, height: 0)
      case .vertical: CGSize(width: 0, height: delta.height)
      default: delta
    }
  }
}
