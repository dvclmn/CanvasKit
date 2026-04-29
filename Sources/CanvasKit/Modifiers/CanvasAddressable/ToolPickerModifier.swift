//
//  ToolPickerModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 29/4/2026.
//

import SwiftUI

public struct ToolPickerModifier: ViewModifier {
  
  let isShowing: Bool
  public func body(content: Content) -> some View {
    content.environment(\.isShowingToolPicker, isShowing)
  }
}

extension View where Self: CanvasAddressable {
  
  /// The minimum zoom range lower bound is `0.05`;
  /// values less than this will be clamped.
  public func toolPicker(_ isShowing: Bool = true) -> ModifiedContent<Self, ToolPickerModifier> {
    self.modifier(
      ToolPickerModifier(isShowing: isShowing)
    )
  }
}
