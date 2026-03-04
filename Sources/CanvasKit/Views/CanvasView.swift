//
//  CanvasView.swift
//  LilyPad
//
//  Created by Dave Coleman on 24/6/2025.
//

import CoreTools
import GestureKit
import SwiftUI

public struct CanvasView<Content: View>: View {
  @Environment(\.viewportRect) private var viewportRect
  @Environment(\.canvasAnchor) private var canvasAnchor
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.shouldShowInfoBarItems) private var shouldShowInfoBarItems
//  @Environment(\.unitSize) private var unitSize

  @State var store = CanvasHandler()

  /// Optional to allow GirdCanvasRect to take advantage of `CanvasCoreView`s
  /// optional unwrapping presentation
  let canvasSize: Size<CanvasSpace>?
  let content: () -> Content

  public init(
    canvasSize: CGSize,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.canvasSize = Size<CanvasSpace>(fromCGSize: canvasSize)
    self.content = content
  }

  public var body: some View {

    CanvasCoreView(
      canvasGeometry: canvasGeometry,
      content: content
    )
    .environment(store)

    .task(id: zoomRange) { store.zoomRange = zoomRange }
    .task(id: canvasGeometry) { store.geometry = canvasGeometry }

    .addInfoBarItems {
      if let zoomRange {
        InfoItems(zoomRange)
      }
    }

    .toolbar {
      ToolbarItem {
        
      }
    }
    .environment(\.canvasSize, canvasSize)
  }
}

extension CanvasView {

  private var canvasGeometry: CanvasGeometry? {
    guard let viewportRect, let canvasSize else { return nil }
    return CanvasGeometry(
      viewportRect: viewportRect,
      canvasSize: canvasSize,
      anchor: canvasAnchor
    )
  }

  @DisplayStringBuilder
  private func InfoItems(_ zoomRange: ClosedRange<Double>) -> [DisplayBlock] {
    if shouldShowInfoBarItems {
      Labeled(
        "Zoom",
        value: store.transform.zoom.value.toPercentString(
          within: zoomRange,
          decimalPlaces: 2
        )
      )
      Labeled(
        "Zoom Range",
        value: "\(zoomRange.lowerBound)...\(zoomRange.upperBound)"
      )
    }
  }
}
