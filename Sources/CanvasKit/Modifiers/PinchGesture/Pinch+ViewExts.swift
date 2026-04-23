//
//  ZoomViewExtensions.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 17/3/2026.
//

import SwiftUI

extension View {

  /// Binding-driven zoom. 
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

/// The caller owns zoom state. The modifier tracks gesture deltas and
/// sends events; the callback returns the resolved zoom value.
extension View {

  /// Return `nil` from `didUpdateZoom` to accept the proposed zoom.
  public func onPinchGesture(
    initial: Double = 1,
    isEnabled: Bool = true,
    didUpdateZoom: @escaping ZoomUpdate,
  ) -> some View {
    self.modifier(
      PinchGestureModifier(
        initial: initial,
        zoom: nil,
        isEnabled: isEnabled,
        didUpdateZoom: didUpdateZoom,
      )
    )
  }
}
