//
//  ToolsPaletteViewModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 3/5/2026.
//

import SwiftUI

struct ToolsPaletteViewModifier: ViewModifier {
  @Environment(\.isShowingToolPalette) private var isShowingToolPalette
  @Environment(\.toolPaletteAlignment) private var toolPaletteAlignment

  func body(content: Content) -> some View {
    content
      .overlay(alignment: toolPaletteAlignment) {
        if isShowingToolPalette {
          ToolsView()
        }
      }
  }
}
