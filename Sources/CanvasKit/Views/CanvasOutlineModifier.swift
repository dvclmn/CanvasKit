//
//  CanvasOutlineModifier.swift
//  BaseComponents
//
//  Created by Dave Coleman on 7/7/2025.
//

import SwiftUI

public struct CanvasOutlineModifier: ViewModifier {
  let canvasHandler: CanvasHandler
  public func body(content: Content) -> some View {
    content
      .debugTextOverlay("Turn canvas outline back on")
      .backgroundTint(.black)
//      .overlay {
//        RoundedRectangle(cornerRadius: canvasHandler.cornerRounding)
//          .fill(.white.opacity(0.009))
//          .stroke(.white.opacity(0.04), lineWidth: canvasOutlineThickness)
//          .allowsHitTesting(false)
//      }
  }
}

//extension CanvasOutlineModifier {
//  var canvasOutlineThickness: CGFloat {
//    return canvasHandler.removeZoom(from: Double(1))
////    return Double(1).removingZoom(canvasHandler.zoomHandler.zoom)
//  }
//}
