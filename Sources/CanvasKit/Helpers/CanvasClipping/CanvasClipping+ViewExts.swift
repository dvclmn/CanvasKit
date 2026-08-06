//
//  CanvasClipping+ViewExts.swift
//  CanvasKit
//
//  Created by Dave Coleman on 6/8/2026.
//

import SwiftUI

extension View {
  /// Controls how this canvas layer is displayed outside the rounded canvas rect.
  @ViewBuilder
  public func canvasClipping(_ clipping: CanvasClipping) -> some View {
    if #available(macOS 15, iOS 18, *) {
      self.containerValue(\.canvasClipping, clipping)
    } else {
      self
    }
  }
  
  /// Controls whether this canvas layer is clipped to the rounded canvas rect.
  @available(*, deprecated, renamed: "canvasClipping(_:)")
  @ViewBuilder
  public func canvasClipped(_ enabled: Bool) -> some View {
    self.canvasClipping(enabled ? .clipped : .none)
  }
}
