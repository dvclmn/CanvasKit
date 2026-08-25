//
//  PinchGestureModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 24/6/2025.
//

private import CoreTools
import SwiftUI
private import ViewTools

/// Converts a SwiftUI `MagnifyGesture` into resolved zoom values.
///
/// The modifier clamps committed zoom values to the current `zoomRange`.
/// While a pinch is active, gesture proposals take precedence over concurrent
/// external binding changes so neither source resets the in-progress gesture.
public struct PinchGestureModifier: ViewModifier {
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.zoomSensitivity) private var zoomSensitivity

  /// Source of truth during the gesture.
  @State private var internalZoom: Double

  /// Zoom level captured at the beginning of the current magnify gesture.
  @State private var gestureStartZoom: Double = 1

  /// Prevents external binding updates from resetting in-progress gestures.
  @State private var isGesturing: Bool = false

  private let externalZoom: Binding<Double>?

  let isEnabled: Bool
  let resolve: ZoomResolver

  init(
    initialZoom: Double,
    zoom: Binding<Double>? = nil,
    isEnabled: Bool,
    resolve: @escaping ZoomResolver,
  ) {
    self._internalZoom = State(initialValue: initialZoom)
    self.externalZoom = zoom
    self.isEnabled = isEnabled
    self.resolve = resolve
  }

  public func body(content: Content) -> some View {
    content
      .gesture(magnifyGesture, isEnabled: isEnabled)

      // The latest bound value wins if it changed between initialisation and insertion.
      .onAppear {
        synchroniseIdleZoom(from: externalZoom?.wrappedValue ?? internalZoom)
      }

      // External source changed (e.g. reset / slider / programmatic change).
      .onChange(of: externalZoom?.wrappedValue) { _, newValue in
        guard let newValue else { return }
        synchroniseIdleZoom(from: newValue)
      }

      // Disabling an active gesture returns ownership to the external source.
      .onChange(of: isEnabled) { _, isEnabled in
        guard !isEnabled else { return }
        isGesturing = false
        synchroniseIdleZoom(from: externalZoom?.wrappedValue ?? internalZoom)
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
          ZoomProposal(
            proposedZoom: proposedZoom,
            phase: .changed,
          )
        )
        commitZoom(resolved)
      }
      .onEnded { value in
        let previousZoom = internalZoom
        let finalZoom = clamped(previousZoom)
        let resolved = resolvedZoom(
          ZoomProposal(
            proposedZoom: finalZoom,
            phase: .ended,
          )
        )
        commitZoom(resolved)

        isGesturing = false
        gestureStartZoom = resolved
      }
  }

  private func resolvedZoom(_ proposal: ZoomProposal) -> Double {
    PinchZoomComputation.resolvedZoom(
      proposal,
      in: zoomRange,
      resolve: resolve,
    )
  }

  private func clamped(_ value: Double) -> Double {
    value.clamped(to: zoomRange)
  }

  private func commitZoom(_ value: Double) {
    internalZoom = value
    externalZoom?.wrappedValue = value
  }

  private func synchroniseIdleZoom(from value: Double) {
    guard !isGesturing else { return }

    let resolved = clamped(value)
    internalZoom = resolved
    gestureStartZoom = resolved

    if let externalZoom, externalZoom.wrappedValue != resolved {
      externalZoom.wrappedValue = resolved
    }
  }
}

enum PinchZoomComputation {
  static let defaultSensitivity: Double = 0.5

  static func proposedZoom(
    startZoom: Double,
    magnification: Double,
    sensitivity: Double = defaultSensitivity,
  ) -> Double {
    let safeStartZoom = startZoom.isFiniteAndPositive ? startZoom : 1
    return safeStartZoom
      * responseFactor(
        magnification,
        sensitivity: sensitivity,
      )
  }

  static func resolvedZoom(
    _ proposal: ZoomProposal,
    in range: ClosedRange<Double>,
    resolve: ZoomResolver,
  ) -> Double {
    resolve(proposal).clamped(to: range)
  }

  static func responseFactor(
    _ magnification: Double,
    sensitivity: Double = defaultSensitivity,
  ) -> Double {
    guard magnification.isFinite else { return 1 }

    let normalisedMagnification = max(magnification, 0)
    let responseStrength = responseStrength(for: sensitivity)
    guard responseStrength.isFiniteAndPositive else {
      return normalisedMagnification
    }
    return exp((normalisedMagnification - 1) * responseStrength)
  }

  static func responseStrength(for sensitivity: Double) -> Double {
    let normalisedSensitivity =
      sensitivity.isFinite
      ? sensitivity.clamped(to: 0...1)
      : defaultSensitivity

    // Maps user sensitivity to exponential response in powers of two.
    //
    // - `0.0`: gentle, full inward pinch gives `0.5x`
    // - `0.5`: standard, full inward pinch gives `0.25x`
    // - `1.0`: strong, full inward pinch gives `0.125x`
    return log(2) * (1 + 2 * normalisedSensitivity)
  }
}
