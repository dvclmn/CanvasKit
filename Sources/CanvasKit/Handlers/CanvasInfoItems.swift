//
//  CanvasInfoItems.swift
//  BaseComponents
//
//  Created by Dave Coleman on 9/7/2025.
//

import BaseUI
import CoreTools
import SwiftUI

public enum CanvasSectionKey: InfoBarSectionKey {
  public static let title = "Canvas"
}

enum CanvasInfoItem: String, CaseIterable, Identifiable, InfoBarItemDescriptor {

  typealias Source = CanvasHandler
  typealias SectionKey = CanvasSectionKey

  case pan
  case zoomActual
  case zoomPercent
  case canvasSize
  case viewportSize
  case pointerInteraction

  var id: String { rawValue }

  var labelText: String {
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

  func content(
    from source: CanvasHandler,
    format: FloatDisplayFormat = .default
  ) -> String {
    let displayFormat: FloatDisplayFormat = .init(
      decimalPlaces: 0,
      labelStyle: .none,
      separatorVisibility: .component
    )
    return switch self {
      case .pan: source.pan.render(using: displayFormat.with(integerLength: 3))
      case .zoomActual: source.zoom.displayString
      case .zoomPercent: source.zoom.toPercentString(within: 0...1)
      case .canvasSize: source.geometry.canvasSize.render(using: displayFormat)
      case .viewportSize: source.geometry.viewportSize.render(using: displayFormat)
      case .pointerInteraction: source.currentPointerInteraction?.name ?? "None"
    }

  }
  //  func content(_ handler: CanvasHandler) -> String {
  //
  //  }
}
