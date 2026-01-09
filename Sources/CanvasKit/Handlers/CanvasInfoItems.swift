//
//  CanvasInfoItems.swift
//  BaseComponents
//
//  Created by Dave Coleman on 9/7/2025.
//

import CoreTools
import SwiftUI

enum CanvasInfoItem: CaseIterable, Identifiable {
  case pan
  case zoomPercent
  case canvasSize
  case interaction
  case modifiers

  static var sectionTitle: String { "Canvas" }

  var id: String { title }

  var title: String {
    switch self {
      case .pan: "Pan"
      case .zoomPercent: "Zoom"
      case .canvasSize: "Canvas Size"
      case .interaction: "Interaction"
      case .modifiers: "Modifiers"
    }
  }

  var icon: IconLiteral {
    switch self {
      case .pan: .symbol(Icons.pan.icon)
      case .zoomPercent: .customSymbol(.zoom)
      case .canvasSize: .symbol(Icons.dimensions.icon)
      case .interaction: .symbol(Icons.library.icon)
      case .modifiers: .symbol("keyboard")
    }
  }

  
  func content(_ canvasHandler: CanvasHandler, modifierKeys: Modifiers) -> AttributedString {
//    print("Need to fix this")
//    return AttributedString("?")
    return switch self {
      case .pan: canvasHandler.panOffset.displayString.toAttributed
//        canvasHandler.panHandler.pan.displayString(places: 0).toAttributed

      case .zoomPercent: canvasHandler.zoomPercent.displayString.toAttributed
//        AttributedString(canvasHandler.zoomHandler.percentString)

      case .canvasSize: canvasHandler.canvasSize?.displayString.toAttributed ?? "nil"
//        canvasHandler.geometry.canvasSize?.displayString(places: 0).toAttributed ?? "nil"
//        canvasHandler.geometry.canvasSize?.displayStringStyled(.fractionLength(0)) ?? "nil"

      case .interaction: canvasHandler.gestureHandler.interactions.interaction.name.toAttributed

      case .modifiers: modifierKeys.displayName(elements: .icon, separator: "", emptyText: "").toAttributed
//        AttributedString(modifierKeys.displayName(elements: .icon, separator: "", emptyText: ""))
    }
  }
}
