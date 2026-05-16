//
//  ToolsPaletteViewModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 3/5/2026.
//

import SwiftUI

struct ToolsPaletteViewModifier: ViewModifier {
  @Environment(\.isShowingToolPicker) private var isShowingToolPicker
  @Environment(\.toolPickerAlignment) private var toolPickerAlignment

  func body(content: Content) -> some View {
    content
      .overlay(alignment: toolPickerAlignment) {
        if isShowingToolPicker {
          ToolsView()
        }
      }
  }
}
