//
//  ZoomViewExtensions.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 17/3/2026.
//

import SwiftUI

// MARK: - Mode A: Binding

/// The modifier owns zoom state and writes clamped values to the binding.
/// Use when you just need a zoomable view without custom zoom logic.

extension View {

  /// Simple binding-driven zoom. The modifier handles gesture math and clamping.
  public func onPinchGesture(
    zoom: Binding<Double>,
    isEnabled: Bool = true
  ) -> some View {
    self.modifier(
      ZoomModifier(
        initial: zoom.wrappedValue,
        zoom: zoom,
        isEnabled: isEnabled,
        didUpdateZoom: { _, _ in nil }
      )
    )
  }

//  /// Simple binding-driven zoom (CGFloat convenience).
//  public func onPinchGesture(
//    zoom: Binding<CGFloat>,
//    isEnabled: Bool = true
//  ) -> some View {
//    self.onPinchGesture(
//      zoom: zoom.toBindingDouble,
//      isEnabled: isEnabled
//    )
//  }
}

// MARK: - Mode B: Event callback

/// The caller owns zoom state. The modifier tracks gesture deltas and
/// sends events; the callback returns the resolved zoom value.
/// Use when you need focus-preserving zoom, pan adjustment, or custom logic.

extension View {

  /// Event-driven zoom with full ``ZoomGestureEvent`` context.
  /// Return `nil` from `didUpdateZoom` to accept the proposed zoom.
  public func onPinchGesture(
    initial: Double = 1,
    isEnabled: Bool = true,
    didUpdateZoom: @escaping ZoomUpdate
//    didUpdateZoom: @escaping ZoomEventUpdate
  ) -> some View {
    self.modifier(
      ZoomModifier(
        initial: initial,
        zoom: nil,
        isEnabled: isEnabled,
        didUpdateZoom: didUpdateZoom
      )
    )
  }

  /// Simplified event-driven zoom receiving just `(proposedZoom, phase)`.
  /// Return `nil` from `didUpdateZoom` to accept the proposed zoom.
//  public func onPinchGesture(
//    initial: Double = 1,
//    isEnabled: Bool = true,
//    didUpdateZoom: @escaping ZoomUpdate
//  ) -> some View {
//    self.modifier(
//      ZoomModifier(
//        initial: initial,
//        zoom: nil,
//        isEnabled: isEnabled,
//        didUpdateZoom: { event, phase in
//          didUpdateZoom(event.proposedZoom, phase)
//        }
//      )
//    )
//  }
}
