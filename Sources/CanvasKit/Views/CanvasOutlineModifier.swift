//
//  CanvasOutlineModifier.swift
//  BaseComponents
//
//  Created by Dave Coleman on 7/7/2025.
//

import BasePrimitives
import SwiftUI

public struct CanvasOutlineModifier: ViewModifier {
  @Environment(\.zoomLevel) private var zoomLevel
  @Environment(\.zoomRange) private var zoomRange

  public func body(content: Content) -> some View {
    content
      .clipShape(.rect(cornerRadius: cornerRounding))
      .overlay {
        RoundedRectangle(cornerRadius: cornerRounding)
          .fill(.clear)
          .stroke(.white.opacity(0.07), lineWidth: outlineThickness)
          .allowsHitTesting(false)
      }
    //      .environment(\.canvasRounding, cornerRounding)
  }
}

extension CanvasOutlineModifier {
  private var cornerRounding: CGFloat {
    let base = Styles.sizeTiny
    return base.removingZoom(zoomLevel)
  }

  var outlineThickness: CGFloat {
    let base = 1.0
    return base.removingZoom(zoomLevel, clampedTo: zoomRange)
  }
}
