//
//  CanvasView+Extensions.swift
//  CanvasKit
//
//  Created by Dave Coleman on 6/4/2026.
//

import SwiftUI

public protocol CanvasAddressable {}

/// Preserve CanvasAddressable across SwiftUI modifiers.
extension ModifiedContent: CanvasAddressable where Content: CanvasAddressable {}

extension View where Self: CanvasAddressable {

  public func zoomRange(_ range: ClosedRange<Double>) -> ModifiedContent<Self, ZoomRangeModifier> {
    self.modifier(ZoomRangeModifier(range: range))
  }

  public func artworkOutline(
    colour: Color = .white.opacity(0.07),
    rounding: CGFloat = 4,
    lineWidth: CGFloat = 1,
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
