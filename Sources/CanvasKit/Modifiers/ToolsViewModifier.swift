//
//  ToolsViewModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 3/5/2026.
//

import SwiftUI

struct ToolsViewModifier: ViewModifier {
  @Environment(CanvasHandler.self) private var store
  @Environment(\.isShowingToolPicker) private var isShowingToolPicker
  @Environment(\.toolPickerAlignment) private var toolPickerAlignment

//  @Binding var transform: TransformState

  func body(content: Content) -> some View {
    content
      .overlay(alignment: toolPickerAlignment) {
        if isShowingToolPicker {
          ToolsView()
        }
      }
  }
}
extension View {
  public func toolPalette() -> some View {
    self.modifier(ToolsViewModifier())
  }
}
