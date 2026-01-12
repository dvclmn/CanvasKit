//
//  CanvasInfoItems.swift
//  BaseComponents
//
//  Created by Dave Coleman on 9/7/2025.
//

import BaseUI
import CoreTools
import SwiftUI

enum CanvasInfoItem: CaseIterable, Identifiable, InfoBarSection {
  case pan
  case zoomPercent
  case canvasSize
  case interaction
  //  case modifiers

  static var sectionTitle: String { "Canvas" }

  var id: String { title }

  var title: String {
    switch self {
      case .pan: "Pan"
      case .zoomPercent: "Zoom"
      case .canvasSize: "Canvas Size"
      case .interaction: "Interaction"
    //      case .modifiers: "Modifiers"
    }
  }

  var icon: IconLiteral {
    switch self {
      case .pan: .symbol(Icons.pan.icon)
      case .zoomPercent: .customSymbol(.zoom)
      case .canvasSize: .symbol(Icons.dimensions.icon)
      case .interaction: .symbol(Icons.library.icon)
    }
  }

  static func buildItems(from source: CanvasHandler) -> [InfoBarItem] {
    allCases.map { item in
      InfoBarItem(
        sectionKey: sectionTitle,
        label: QuickLabel(item.title, icon: item.icon),
        content: item.content(source)
      )
    }
  }

  func content(_ handler: CanvasHandler) -> String {
    return switch self {
      case .pan: handler.panOffset.displayString
//      case .zoomPercent: handler.zoomPercentage.displayString
//      case .canvasSize: handler.canvasSize?.displayString ?? "nil"
//      case .interaction: handler.interactions.active.debugDescription
      case .zoomPercent, .canvasSize, .interaction: "Not Implemented"
    }
  }
}
