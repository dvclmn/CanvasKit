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
