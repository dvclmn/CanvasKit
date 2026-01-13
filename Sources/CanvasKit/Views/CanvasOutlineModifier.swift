//
//  CanvasOutlineModifier.swift
//  BaseComponents
//
//  Created by Dave Coleman on 7/7/2025.
//

import BasePrimitives
import SwiftUI

public struct CanvasOutlineModifier: ViewModifier {
  @Environment(\.canvasZoom) private var canvasZoom
  //  @Environment(\.canvasHandler) private var canvasHandler

  public func body(content: Content) -> some View {
    content
      .clipShape(.rect(cornerRadius: cornerRounding))
      .overlay {
        RoundedRectangle(cornerRadius: cornerRounding)
          .fill(.clear)
          .stroke(.white.opacity(0.09), lineWidth: outlineThickness)
          .allowsHitTesting(false)
      }
  }
}

extension CanvasOutlineModifier {
  private var cornerRounding: CGFloat {
    let base = Styles.sizeTiny
    return base.removingZoom(canvasZoom)
  }

  var outlineThickness: CGFloat {
    let base = 1.0
    return base.removingZoom(canvasZoom, clampedTo: 1...20)
    //    let line = canvasHandler.removeZoom(from: Double(1))
    //    return Double(1).removingZoom(canvasHandler.zoomHandler.zoom)
  }
}
