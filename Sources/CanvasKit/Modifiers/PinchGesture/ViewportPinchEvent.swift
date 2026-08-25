//
//  ViewportPinchEvent.swift
//  CanvasKit
//
//  Created by Dave Coleman on 30/7/2026.
//

import Foundation
private import CoreTools

/// A neutral magnification input sample from a pinch gesture.
///
/// Unlike CanvasKit's zoom gesture APIs, this event contains no zoom range,
/// sensitivity, or bound transform policy.
public struct ViewportPinchEvent: Sendable, Equatable {

  /// Magnification relative to the start of the gesture.
  ///
  /// A value of `1` means the gesture has not changed scale.
  public let magnification: Double

  /// Magnification relative to the previous emitted event.
  ///
  /// A value of `1` means there is no new scale change to apply.
  public let magnificationDelta: Double

  /// The resolved lifecycle phase for this input sample.
  public let phase: InteractionPhase

  public init(
    magnification: Double,
    magnificationDelta: Double,
    phase: InteractionPhase,
  ) {
    self.magnification = magnification
    self.magnificationDelta = magnificationDelta
    self.phase = phase
  }
}

public typealias ViewportPinchOutput = (ViewportPinchEvent) -> Void

/// Derives coherent incremental events from start-relative magnification.
///
/// Kept separate from the SwiftUI modifier so its lifecycle and numerical
/// guarantees can be tested without synthesising platform gesture input.
struct ViewportPinchEventAccumulator {
  private(set) var previousMagnification: Double = 1
  private(set) var isActive = false

  mutating func changed(
    magnification: Double
  ) -> ViewportPinchEvent? {
    guard let event = event(
      magnification: magnification,
      phase: isActive ? .changed : .began,
    ) else {
      return nil
    }

    previousMagnification = event.magnification
    isActive = true
    return event
  }

  mutating func ended(
    magnification: Double
  ) -> ViewportPinchEvent? {
    guard isActive else {
      reset()
      return nil
    }

    let event =
      event(
        magnification: magnification,
        phase: .ended,
      )
      ?? ViewportPinchEvent(
        magnification: previousMagnification,
        magnificationDelta: 1,
        phase: .ended,
      )

    reset()
    return event
  }

  mutating func reset() {
    previousMagnification = 1
    isActive = false
  }

  private func event(
    magnification: Double,
    phase: InteractionPhase,
  ) -> ViewportPinchEvent? {
    guard magnification.isFiniteAndPositive else { return nil }

    let delta = magnification / previousMagnification
    guard delta.isFiniteAndPositive else { return nil }

    return ViewportPinchEvent(
      magnification: magnification,
      magnificationDelta: delta,
      phase: phase,
    )
  }
}
