//
//  ZoomViewModifier.swift
//  LilyPad
//
//  Created by Dave Coleman on 24/6/2025.
//

import SwiftUI
import BasePrimitives

/// Return a replacement zoom value for `(proposedZoom, phase)`,
/// or `nil` to accept the gesture's proposal
public typealias ZoomUpdate = (Double, InteractionPhase) -> Double?

/// Converts `MagnifyGesture` into incremental zoom deltas and
/// routes them through one of two ownership modes:
///
/// ## Mode A — Binding
/// ```swift
/// .onPinchGesture(zoom: $myZoom)
/// ```
/// The modifier owns the gesture math, clamps to `zoomRange`, and writes the
/// result directly to the binding. No override callback — the binding is the
/// single source of truth.
///
/// ## Mode B — Event callback
/// ```swift
/// .onPinchGesture(initial: currentZoom, didUpdateZoom: { event in ... })
/// ```
/// The modifier tracks deltas internally, but the **caller** owns the zoom
/// value. The callback receives a ``ZoomGestureEvent`` and returns the
/// resolved zoom (or `nil` to accept the proposal). The caller is responsible
/// for writing the result to its own state.
///
/// > Important: Do **not** combine a binding with an override callback.
/// > That creates two writers for the same value and leads to double-writes.
/// > Use Mode A *or* Mode B, not both.
public struct PinchGestureModifier: ViewModifier {
  @Environment(\.zoomRange) private var zoomRange

  /// Source of truth during the gesture.
  @State private var internalZoom: Double

  /// Tracks incremental deltas within the current magnify gesture.
  @State private var lastMagnification: Double = 1

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
        /// Only adopt it when we are NOT currently gesturing.
        guard !isGesturing, let newValue else { return }
        internalZoom = clamped(newValue)
      }
  }
}

extension PinchGestureModifier {
  private var magnifyGesture: some Gesture {
    MagnifyGesture(minimumScaleDelta: 0.01)
      .onChanged { value in
        let isGestureStart = !isGesturing
        if isGestureStart { lastMagnification = 1 }
        
        isGesturing = true

        let delta = getDelta(from: value)
        lastMagnification = value.magnification

        let previousZoom = internalZoom
        let proposedZoom = previousZoom * delta

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
        lastMagnification = 1
      }
  }

  private func resolvedZoom(
    phase: InteractionPhase,
    proposed: Double,
  ) -> Double {
    clamped(didUpdateZoom(proposed, phase) ?? proposed)
  }

  /// MagnifyGesture reports absolute scale since start; convert to delta.
  private func getDelta(from value: MagnifyGesture.Value) -> Double {
    let safeLast =
      lastMagnification.isFiniteAndGreaterThanZero
      ? lastMagnification
      : 1

    return value.magnification / safeLast
  }

  private func clamped(_ value: Double) -> Double {
    value.clampedIfNeeded(to: zoomRange)
  }

  private func commitZoom(_ value: Double) {
    internalZoom = value
    externalZoom?.wrappedValue = value
  }
}
