//
//  ToolPickerModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 29/4/2026.
//

import SwiftUI

public struct ToolPickerModifier: ViewModifier {

  let isShowing: Bool
  let alignment: Alignment
  public func body(content: Content) -> some View {
    content
      .environment(\.isShowingToolPicker, isShowing)
      .environment(\.toolPickerAlignment, alignment)
  }
}

extension View where Self: CanvasAddressable {

  /// The minimum zoom range lower bound is `0.05`;
  /// values less than this will be clamped.
  public func toolPicker(
    _ isShowing: Bool = true,
    alignment: Alignment = .topLeading,
  ) -> ModifiedContent<Self, ToolPickerModifier> {
    self.modifier(
      ToolPickerModifier(isShowing: isShowing, alignment: alignment)
    )
  }
}
