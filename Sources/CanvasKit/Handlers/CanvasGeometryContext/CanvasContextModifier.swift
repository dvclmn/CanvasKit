//
//  CanvasContextModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 11/1/2026.
//

import SwiftUI

public struct CanvasContextModifier: ViewModifier {
  @Environment(\.canvasZoom) private var canvasZoom
  @Environment(\.canvasPan) private var canvasPan
  @Environment(\.canvasRotation) private var canvasRotation
  @Environment(\.canvasSize) private var canvasSize
  @Environment(\.viewportSize) private var viewportSize
  
  
  public func body(content: Content) -> some View {
    content
  }
}

extension CanvasContextModifier {
  var canvasContext: CanvasTransformContext {
    
  }
}
extension View {
  public func example() -> some View {
    self.modifier(ExampleModifier())
  }
}
