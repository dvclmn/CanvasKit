//
//  ZoomViewModifier.swift
//  Lilypad
//
//  Created by Dave Coleman on 24/6/2025.
//

import CoreTools
import SwiftUI
import ViewTools

/// Return a replacement zoom value for `(proposedZoom, phase)`,
/// or `nil` to accept the gesture's proposal
///
/// Note: Zoom `Double` value not clamped. This is handled per-domain.
public struct PinchGestureModifier: ViewModifier {
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.zoomSensitivity) private var zoomSensitivity

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

      // External source changed (e.g. reset / slider / programmatic change).
      .onChange(of: externalZoom?.wrappedValue) { _, newValue in
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
          sensitivity: zoomSensitivity,
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
  static let defaultSensitivity: Double = 0.5

  static func proposedZoom(
    startZoom: Double,
    magnification: Double,
    sensitivity: Double = defaultSensitivity,
  ) -> Double {
    let safeStartZoom = startZoom.isFiniteAndGreaterThanZero ? startZoom : 1
    return safeStartZoom
      * responseFactor(
        magnification,
        sensitivity: sensitivity,
      )
  }

  static func responseFactor(
    _ magnification: Double,
    sensitivity: Double = defaultSensitivity,
  ) -> Double {
    guard magnification.isFinite else { return 1 }

    let normalisedMagnification = max(magnification, 0)
    let responseStrength = responseStrength(for: sensitivity)
    guard responseStrength.isFiniteAndGreaterThanZero else {
      return normalisedMagnification
    }
    return exp((normalisedMagnification - 1) * responseStrength)
  }

  static func responseStrength(for sensitivity: Double) -> Double {
    let normalisedSensitivity =
      sensitivity.isFinite
      ? sensitivity.clamped(to: 0...1)
      : defaultSensitivity

    /// Maps user sensitivity to exponential response in powers of two.
    ///
    /// - `0.0`: gentle, full inward pinch gives `0.5x`
    /// - `0.5`: standard, full inward pinch gives `0.25x`
    /// - `1.0`: strong, full inward pinch gives `0.125x`
    return log(2) * (1 + 2 * normalisedSensitivity)
  }
}
