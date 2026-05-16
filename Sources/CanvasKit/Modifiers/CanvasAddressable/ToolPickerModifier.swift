//
//  ToolPickerModifier.swift
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
      .environment(\.isShowingToolPicker, isShowing)
      .environment(\.toolPickerAlignment, alignment)
  }
}

extension View where Self: CanvasAddressable {

  public func toolPicker(
    _ isShowing: Bool = true,
    alignment: Alignment = .topLeading,
  ) -> ModifiedContent<Self, ToolsPaletteEnvironmentModifier> {
    self.modifier(
      ToolsPaletteEnvironmentModifier(isShowing: isShowing, alignment: alignment)
    )
  }
}
