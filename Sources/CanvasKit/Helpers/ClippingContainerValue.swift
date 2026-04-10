//
//  CanvasClippingContainerValue.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 28/2/2026.
//

import SwiftUI

extension View {
  /// Controls whether this canvas layer is clipped to the rounded canvas rect.
  @ViewBuilder
  public func allowsCanvasClipping(_ enabled: Bool) -> some View {
    if #available(macOS 15, iOS 18, *) {
      self.containerValue(\.allowsCanvasClipping, enabled)
    } else {
      self
    }
  }
}

@available(macOS 15, iOS 18, *)
extension ContainerValues {
  @Entry public var allowsCanvasClipping: Bool = true
}
