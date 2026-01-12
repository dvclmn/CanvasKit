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
  case zoomActual
  case zoomPercent
  case canvasSize
  case viewportSize
//  case interaction
  //  case modifiers

  static var sectionTitle: String { "Canvas" }

  var id: String { title }

  var title: String {
    switch self {
      case .pan: "Pan"
      case .zoomActual: "Zoom Actual"
      case .zoomPercent: "Zoom"
      case .canvasSize: "Canvas Size"
      case .viewportSize: "Viewport Size"
//      case .interaction: "Interaction"
    //      case .modifiers: "Modifiers"
    }
  }

  var icon: IconLiteral {
    switch self {
      case .pan: .symbol(Icons.pan.icon)
      case .zoomActual: .symbol(Icons.antenna.icon)
      case .zoomPercent: .symbol(Icons.search.icon)
//      case .zoomPercent: .customSymbol(.zoom)
      case .canvasSize: .symbol(Icons.dimensions.icon)
      case .viewportSize: .symbol(Icons.dimensions.icon)
//      case .interaction: .symbol(Icons.library.icon)
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
    let displayFormat: DisplayFormat = .init(
      decimalPlaces: 0,
      labelStyle: .none,
      separatorVisibility: .component
    )
    return switch self {
      case .pan: handler.pan.render(using: displayFormat)
      case .zoomActual: handler.zoom.displayString
      case .zoomPercent: handler.zoom.toPercentString(within: 0...1)
      case .canvasSize: handler.geometry.canvasSize.render(using: displayFormat)
      case .viewportSize: handler.geometry.viewportSize.render(using: displayFormat)
//      case .interaction: handler.interactions.active.debugDescription
//      case .canvasSize, .interaction: "Not Implemented"
    }
  }
}
