//
//  CanvasOutlineModifier.swift
//  BaseComponents
//
//  Created by Dave Coleman on 7/7/2025.
//

import SwiftUI

public struct CanvasOutlineModifier: ViewModifier {
  @Environment(\.canvasHandler) private var canvasHandler

  public func body(content: Content) -> some View {
    content
      .clipShape(.rect(cornerRadius: canvasHandler.cornerRounding))
      .overlay {
        RoundedRectangle(cornerRadius: canvasHandler.cornerRounding)
          .fill(.clear)
          .stroke(.white.opacity(0.09), lineWidth: canvasOutlineThickness)
          .allowsHitTesting(false)
      }
  }
}

extension CanvasOutlineModifier {
  var canvasOutlineThickness: CGFloat {
    let line = canvasHandler.removeZoom(from: Double(1))
    return max(1, min(20, line))
    //    return Double(1).removingZoom(canvasHandler.zoomHandler.zoom)
  }
}
