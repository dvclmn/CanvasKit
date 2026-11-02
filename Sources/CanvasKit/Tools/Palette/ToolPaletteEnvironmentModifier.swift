//
//  ToolPaletteEnvironmentModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 29/4/2026.
//

import SwiftUI

public struct ToolPaletteEnvironmentModifier: ViewModifier {

  let isShowing: Bool
  //  let alignment: Alignment
  let configuration: ToolPaletteConfiguration
  public func body(content: Content) -> some View {
    content
      .environment(\.isShowingToolPalette, isShowing)
    //      .environment(\.toolPaletteAlignment, alignment)
  }
}

extension View where Self: CanvasAddressable {
  public func toolPalette(
    isEnabled: Bool = true,
    alignment: Alignment = .topLeading,
    width: CGFloat? = nil,
    horizontalPadding: CGFloat? = nil,
  ) -> ModifiedContent<Self, ToolPaletteEnvironmentModifier> {
    self.modifier(
      ToolPaletteEnvironmentModifier(
        isShowing: isEnabled,
        configuration: .init(
          alignment: alignment,
          width: width ?? ToolPaletteConfiguration.defaultWidth,
          paddingH: horizontalPadding ?? ToolPaletteConfiguration.defaultPaddingH,
        ),
      )
    )
  }
}
