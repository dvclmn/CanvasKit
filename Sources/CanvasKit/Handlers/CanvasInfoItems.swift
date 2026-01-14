//
//  CanvasInfoItems.swift
//  BaseComponents
//
//  Created by Dave Coleman on 9/7/2025.
//

import BaseUI
import CoreTools
import SwiftUI

enum CanvasInfoItem: String, CaseIterable, Identifiable, InfoBarSection {

  typealias Source = CanvasHandler

  case pan
  case zoomActual
  case zoomPercent
  case canvasSize
  case viewportSize
  case pointerInteraction
  //  case modifiers

  static var sectionTitle: String { "Canvas" }

  var id: String { title }

  var title: String {
    switch self {
      case .zoomActual: "Zoom Actual"
      case .zoomPercent: "Zoom Percent"
      case .canvasSize: "Canvas Size"
      case .viewportSize: "Viewport Size"
      case .pointerInteraction: "Pointer Interaction"
      case .pan: rawValue.capitalized
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
      case .pointerInteraction: .symbol(Icons.cursor.icon)
    //      case .interaction: .symbol(Icons.library.icon)
    }
  }

  //  static func buildItems(from source: CanvasHandler) -> [InfoBarItem] {
  //    allCases.map { item in
  //      InfoBarItem(
  //        sectionKey: sectionTitle,
  //        label: QuickLabel(item.title, icon: item.icon),
  //        content: item.content(source)
  //      )
  //    }
  //  }

  func getContent(
    from source: CanvasHandler,
    format: DisplayFormat = .default
  ) -> String {
    let displayFormat: DisplayFormat = .init(
      decimalPlaces: 0,
      labelStyle: .none,
      separatorVisibility: .component
    )
    return switch self {
      case .pan: source.pan.render(using: displayFormat)
      case .zoomActual: source.zoom.displayString
      case .zoomPercent: source.zoom.toPercentString(within: 0...1)
      case .canvasSize: source.geometry.canvasSize.render(using: displayFormat)
      case .viewportSize: source.geometry.viewportSize.render(using: displayFormat)
      case .pointerInteraction: source.pointerState.currentInteraction?.name ?? "None"
    //      case .interaction: handler.interactions.active.debugDescription
    //      case .canvasSize, .interaction: "Not Implemented"
    }

  }
  //  func content(_ handler: CanvasHandler) -> String {
  //
  //  }
}
