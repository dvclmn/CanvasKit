//
//  CanvasSizeFrame.swift
//  CanvasKit
//
//  Created by Dave Coleman on 3/5/2026.
//

import SwiftUI

struct CanvasSizeFrameModifier: ViewModifier {
  @Environment(\.canvasSize) private var canvasSize
  
  func body(content: Content) -> some View {
    content
      .frame(
        width: canvasSize?.width,
        height: canvasSize?.height,
      )

  }
}
extension View {
  public func canvasSizeFrame() -> some View {
    self.modifier(CanvasSizeFrameModifier())
  }
}
