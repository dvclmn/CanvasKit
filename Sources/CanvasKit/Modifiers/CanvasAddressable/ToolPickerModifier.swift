//
//  ToolPaletteModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 29/4/2026.
//

import SwiftUI

public struct ToolsPaletteEnvironmentModifier: ViewModifier {

  let isShowing: Bool
  let alignment: Alignment
  public func body(content: Content) -> some View {
    content
      .environment(\.isShowingToolPalette, isShowing)
      .environment(\.toolPaletteAlignment, alignment)
  }
}

extension View where Self: CanvasAddressable {

  public func toolPalette(
    _ isShowing: Bool = true,
    alignment: Alignment = .topLeading,
  ) -> ModifiedContent<Self, ToolsPaletteEnvironmentModifier> {
    self.modifier(
      ToolsPaletteEnvironmentModifier(isShowing: isShowing, alignment: alignment)
    )
  }
}
