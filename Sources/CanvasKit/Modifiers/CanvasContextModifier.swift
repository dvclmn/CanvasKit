//
//  CanvasContextModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 11/1/2026.
//

import SwiftUI

//public struct CanvasContextModifier: ViewModifier {
//  @Environment(\.canvasZoom) private var canvasZoom
//  @Environment(\.panOffset) private var panOffset
//  @Environment(\.canvasRotation) private var canvasRotation
//  @Environment(\.canvasSize) private var canvasSize
//  @Environment(\.viewportSize) private var viewportSize
//
//  public func body(content: Content) -> some View {
//    content
//      .environment(\.canvasContext, canvasContext)
//  }
//}
//
//extension CanvasContextModifier {
//  
//  var canvasContext: CanvasTransformContext? {
//    CanvasTransformContext(
//      viewportSize: viewportSize,
//      canvasSize: canvasSize,
//      zoom: canvasZoom,
//      pan: panOffset,
//      rotation: canvasRotation
//    )
//
//  }
//}
//extension View {
//  public func readCanvasContext() -> some View {
//    self.modifier(CanvasContextModifier())
//  }
//}
