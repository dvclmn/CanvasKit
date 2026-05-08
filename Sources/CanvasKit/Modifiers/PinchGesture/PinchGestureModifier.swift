//
//  ZoomViewModifier.swift
//  Lilypad
//
//  Created by Dave Coleman on 24/6/2025.
//

import InputPrimitives
import Foundation
import SwiftUI

/// Return a replacement zoom value for `(proposedZoom, phase)`,
/// or `nil` to accept the gesture's proposal
///
/// Note: Zoom `Double` value not clamped. This is handled per-domain.
public typealias ZoomUpdate = (Double, InteractionPhase) -> Double?

public struct PinchGestureModifier: ViewModifier {
  @Environment(\.zoomRange) private var zoomRange

  /// Source of truth during the gesture.
  @State private var internalZoom: Double

  /// Zoom level captured at the beginning of the current magnify gesture.
  @State private var gestureStartZoom: Double = 1

  /// Helps with external sync.
  @State private var isGesturing: Bool = false

  private let externalZoom: Binding<Double>?
  let isEnabled: Bool
  let didUpdateZoom: ZoomUpdate

  init(
    initial: Double,
    zoom: Binding<Double>? = nil,
    isEnabled: Bool,
    didUpdateZoom: @escaping ZoomUpdate,
  ) {
    self._internalZoom = State(initialValue: initial)
    self.externalZoom = zoom
    self.isEnabled = isEnabled
    self.didUpdateZoom = didUpdateZoom
  }

  public func body(content: Content) -> some View {
    content
      .gesture(magnifyGesture, isEnabled: isEnabled)

      .onChange(of: externalZoom?.wrappedValue) { _, newValue in
        /// External source changed (e.g. reset button / slider / programmatic change).
        /// Update it when not currently gesturing.
        guard !isGesturing, let newValue else { return }
        internalZoom = clamped(newValue)
        gestureStartZoom = internalZoom
      }
  }
}

extension PinchGestureModifier {
  private var magnifyGesture: some Gesture {
    MagnifyGesture(minimumScaleDelta: 0.01)
      .onChanged { value in
        let isGestureStart = !isGesturing
        if isGestureStart { gestureStartZoom = internalZoom }

        isGesturing = true

        let proposedZoom = PinchZoomComputation.proposedZoom(
          startZoom: gestureStartZoom,
          magnification: value.magnification,
        )

        let resolved = resolvedZoom(
          phase: .changed,
          proposed: proposedZoom,
        )
        commitZoom(resolved)
      }
      .onEnded { value in
        let previousZoom = internalZoom
        let finalZoom = clamped(previousZoom)
        let resolved = resolvedZoom(
          phase: .ended,
          proposed: finalZoom,
        )
        commitZoom(resolved)

        isGesturing = false
        gestureStartZoom = resolved
      }
  }

  private func resolvedZoom(
    phase: InteractionPhase,
    proposed: Double,
  ) -> Double {
    clamped(didUpdateZoom(proposed, phase) ?? proposed)
  }

  private func clamped(_ value: Double) -> Double {
    value.clamped(to: zoomRange)
  }

  private func commitZoom(_ value: Double) {
    internalZoom = value
    externalZoom?.wrappedValue = value
  }
}

enum PinchZoomComputation {
  static let defaultResponseStrength: Double = log(2) / 0.5

  static func proposedZoom(
    startZoom: Double,
    magnification: Double,
    responseStrength: Double = defaultResponseStrength,
  ) -> Double {
    let safeStartZoom = startZoom.isFiniteAndGreaterThanZero ? startZoom : 1
    return safeStartZoom * responseFactor(
      magnification,
      responseStrength: responseStrength,
    )
  }

  static func responseFactor(
    _ magnification: Double,
    responseStrength: Double = defaultResponseStrength,
  ) -> Double {
    guard magnification.isFinite else { return 1 }

    let normalisedMagnification = max(magnification, 0)
    guard responseStrength.isFiniteAndGreaterThanZero else {
      return normalisedMagnification
    }
    return exp((normalisedMagnification - 1) * responseStrength)
  }
}
