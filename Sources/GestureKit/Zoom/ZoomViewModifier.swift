//
//  ZoomViewModifier.swift
//  LilyPad
//
//  Created by Dave Coleman on 24/6/2025.
//

import SwiftUI

/// Return a replacement zoom value, or `nil` to accept the gesture's proposal.
/// It may be that later I use this when doing more complex processing on the zoom
/// value, for zooming around a focus point / cursor etc
@available(
  *, deprecated, renamed: "ZoomUpdate",
  message: "Considering deprecating this more verbose Zoom event type, in favour of simple Double value"
)
public typealias ZoomEventUpdate = (ZoomGestureEvent, InteractionPhase) -> Double?

/// Return a replacement zoom value for `(proposedZoom, phase)`, or `nil` to accept.
public typealias ZoomUpdate = (Double, InteractionPhase) -> Double?

/// Converts `MagnifyGesture` into incremental zoom deltas and routes them
/// through one of two ownership modes:
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
public struct ZoomModifier: ViewModifier {
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
    didUpdateZoom: @escaping ZoomUpdate
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

extension ZoomModifier {
  private var magnifyGesture: some Gesture {
    MagnifyGesture(minimumScaleDelta: 0.01)
      .onChanged { value in
        let isGestureStart = !isGesturing
        if isGestureStart {
          lastMagnification = 1
        }
        isGesturing = true

        /// MagnifyGesture reports absolute scale since start; convert to delta.
        let safeLast =
          lastMagnification.isFiniteAndGreaterThanZero
          ? lastMagnification
          : 1

        let delta = value.magnification / safeLast
        lastMagnification = value.magnification

        let previousZoom = internalZoom
        let proposedZoom = previousZoom * delta

        //        let event = ZoomGestureEvent(
        //          //          phase: .changed,
        //          previousZoom: previousZoom,
        //          proposedZoom: proposedZoom,
        //          magnification: value.magnification,
        //          magnificationDelta: delta,
        //          isGestureStart: isGestureStart
        //        )

        let resolvedZoom = resolvedZoom(
          //          for: event,
          phase: .changed,
          proposed: proposedZoom
        )
        commitZoom(resolvedZoom)
      }
      .onEnded { value in
        let previousZoom = internalZoom
        let finalZoom = clamped(previousZoom)

        //        let event = ZoomGestureEvent(
        //          //          phase: .ended,
        //          previousZoom: previousZoom,
        //          proposedZoom: finalZoom,
        //          magnification: value.magnification,
        //          magnificationDelta: 1,
        //          isGestureStart: false
        //        )

        let resolvedZoom = resolvedZoom(
          phase: .ended,
          proposed: finalZoom
        )
        commitZoom(resolvedZoom)

        isGesturing = false
        lastMagnification = 1
      }
  }

  private func resolvedZoom(
    //    for event: ZoomGestureEvent,
    phase: InteractionPhase,
    proposed: Double
  ) -> Double {
    clamped(didUpdateZoom(proposed, phase) ?? proposed)
  }

  private func clamped(_ value: Double) -> Double {
    value.clampedIfNeeded(to: zoomRange)
  }

  private func commitZoom(_ value: Double) {
    internalZoom = value
    externalZoom?.wrappedValue = value
  }
}
