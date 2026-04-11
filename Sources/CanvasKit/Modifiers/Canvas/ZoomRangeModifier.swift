//
//  CanvasExtensions.swift
//  CanvasKit
//
//  Created by Dave Coleman on 4/4/2026.
//

import SwiftUI

public struct ZoomRangeModifier: ViewModifier {
  
  let range: ClosedRange<Double>
  public func body(content: Content) -> some View {
    content.environment(\.zoomRange, range)
  }
}

extension View where Self: CanvasAddressable {
  public func zoomRange(_ range: ClosedRange<Double>) -> ModifiedContent<Self, ZoomRangeModifier> {
    self.modifier(ZoomRangeModifier(range: range))
  }
}
