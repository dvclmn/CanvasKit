//
//  CanvasSizeFrame.swift
//  CanvasKit
//
//  Created by Dave Coleman on 3/5/2026.
//

import SwiftUI
import StringTools

struct CanvasSizeFrameModifier: ViewModifier {
  
//  let explicitCanvasSize: Size<CanvasSpace>?
  @Environment(\.explicitCanvasSize) private var explicitCanvasSize
  
  func body(content: Content) -> some View {
    content
      .frame(
        width: explicitCanvasSize?.width,
        height: explicitCanvasSize?.height,
      )
      .debugText {
        Labeled("Explicit Canvas Size", value: explicitCanvasSize)
      }

  }
}
extension View {
  public func canvasSizeFrame() -> some View {
    self.modifier(CanvasSizeFrameModifier())
  }
}
