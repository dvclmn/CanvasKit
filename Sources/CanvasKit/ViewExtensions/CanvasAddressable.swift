//
//  CanvasView+Extensions.swift
//  CanvasKit
//
//  Created by Dave Coleman on 6/4/2026.
//

import SwiftUI

/// CanvasView conforms to this, allowing view modifiers that
/// show up only on CanvasView itself, or (see below) modifiers
/// that return a CanvasAddressable View.
public protocol CanvasAddressable {}

/// Preserve CanvasAddressable across SwiftUI modifiers,
/// rather than losing this context via `some View`
extension ModifiedContent: CanvasAddressable where Content: CanvasAddressable {}

extension View where Self: CanvasAddressable {

  public func zoomRange(_ range: ClosedRange<Double>) -> ModifiedContent<Self, ZoomRangeModifier> {
    self.modifier(ZoomRangeModifier(range: range))
  }

  public func artworkOutline(
    colour: Color = .white.opacity(0.07),
    rounding: Double = 4,
    lineWidth: Double = 1,
  ) -> ModifiedContent<Self, ArtworkOutlineModifier> {
    self.modifier(
      ArtworkOutlineModifier(
        colour: colour,
        rounding: rounding,
        lineWidth: lineWidth,
      )
    )
  }
}
