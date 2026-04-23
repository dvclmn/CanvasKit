//
//  CanvasBackgroundModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 11/4/2026.
//

import SwiftUI

public struct CanvasBackgroundModifier: ViewModifier {

  let background: Color
  public func body(content: Content) -> some View {
    content.environment(\.canvasBackground, background)
  }
}

extension View where Self: CanvasAddressable {
  public func canvasBackground(
    _ colour: Color
  ) -> ModifiedContent<Self, CanvasBackgroundModifier> {
    self.modifier(CanvasBackgroundModifier(background: colour))
  }
}
