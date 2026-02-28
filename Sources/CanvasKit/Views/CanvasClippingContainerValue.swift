//
//  CanvasClippingContainerValue.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 28/2/2026.
//

import SwiftUI

extension View {
  public func allowsCanvasClipping(_ enabled: Bool) -> some View {
    self.containerValueBool(.allowsCanvasClipping, enabled)
  }
}
//@available(macOS 15.0, iOS 18.0, *)
//extension ContainerValues {
//  @Entry public var canvasAllowsClipping: Bool = true
//}
//
//extension View {
//  /// Controls whether this canvas layer is clipped to the rounded canvas rect.
//  ///
//  /// Note: This is currently read from direct subviews in `CanvasView` content
//  /// on macOS 15 / iOS 18 and later.
//  public func allowsCanvasClipping(_ isAllowed: Bool) -> some View {
//    if #available(macOS 15.0, iOS 18.0, *) {
//      containerValue(\.canvasAllowsClipping, isAllowed)
//    } else {
//      self
//    }
//  }
//}
