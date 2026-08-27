//
//  ToolPaletteOverlayModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 3/5/2026.
//

import SwiftUI

struct ToolPaletteOverlayModifier: ViewModifier {
  @Environment(\.isShowingToolPalette) private var isShowingToolPalette
  @Environment(\.toolPaletteConfiguration) private var configuration

  func body(content: Content) -> some View {
    content
      .overlay(alignment: configuration.alignment) {
        if isShowingToolPalette {
          ToolPaletteView()
        }
      }
  }
}
