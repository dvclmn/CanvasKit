//
//  ZoomViewExtensions.swift
//  CanvasKit
//
//  Created by Dave Coleman on 17/3/2026.
//

import SwiftUI
import ViewTools
import CoreTools

extension View {

  /// Adds a pinch gesture that writes resolved zoom values to a binding.
  public func onPinchGesture(
    zoom: Binding<Double>,
    isEnabled: Bool = true,
  ) -> some View {
    self.modifier(
      PinchGestureModifier(
        initial: zoom.wrappedValue,
        zoom: zoom,
        isEnabled: isEnabled,
        didUpdateZoom: { _, _ in nil },
      )
    )
  }
}

public typealias ZoomUpdate = (Double, InteractionPhase) -> Double?

extension View {

  /// Adds a pinch gesture that reports proposed zoom values before they commit.
  ///
  /// Return `nil` from `didUpdateZoom` to accept the proposed zoom, or return a
  /// replacement value to apply app-specific policy.
  public func onPinchGesture(
    initial: Double = 1,
    zoom: Binding<Double>? = nil,
    isEnabled: Bool = true,
    didUpdateZoom: @escaping ZoomUpdate,
  ) -> some View {
    self.modifier(
      PinchGestureModifier(
        initial: initial,
        zoom: zoom,
        isEnabled: isEnabled,
        didUpdateZoom: didUpdateZoom,
      )
    )
  }
}
