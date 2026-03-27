//
//  CanvasClippingContainerValue.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 28/2/2026.
//

import SwiftUI

extension View {
  /// Controls whether this canvas layer is clipped to the rounded canvas rect.
  public func allowsCanvasClipping(_ enabled: Bool) -> some View {
    self.containerValueBool(.allowsCanvasClipping, enabled)
  }
}
