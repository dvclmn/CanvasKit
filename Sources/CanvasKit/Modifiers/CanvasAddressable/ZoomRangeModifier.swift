//
//  CanvasExtensions.swift
//  CanvasKit
//
//  Created by Dave Coleman on 4/4/2026.
//

import CoreUtilities
import SwiftUI

public struct ZoomRangeModifier: ViewModifier {

  let range: ClosedRange<Double>
  public func body(content: Content) -> some View {
    content.environment(\.zoomRange, range)
  }
}

extension View where Self: CanvasAddressable {

  /// The minimum zoom range lower bound is `0.05`;
  /// values less than this will be clamped.
  public func zoomRange(_ range: ClosedRange<Double>) -> ModifiedContent<Self, ZoomRangeModifier> {
    self.modifier(
      ZoomRangeModifier(
        range: range.clamped(to: CanvasHandler.Constants.zoomRangeConstrained)
      )
    )
  }
}
