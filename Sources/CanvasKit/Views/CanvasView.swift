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
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.shouldShowInfoBarItems) private var shouldShowInfoBarItems

  @State var store = CanvasHandler()

  let canvasSize: CGSize
  let content: () -> Content

  public init(
    canvasSize: CGSize,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.canvasSize = canvasSize
    self.content = content
  }

  public var body: some View {
    if let viewportRect, let zoomRange {

      CanvasCoreView(content: content)
        .environment(store)
        .environment(\.canvasGeometry, store.geometry)
        .environment(\.canvasSize, canvasSize)
        .task(id: canvasSize) { store.updateCanvasSize(canvasSize) }
        .task(id: viewportRect) { store.updateViewportRect(viewportRect) }
        .task(id: zoomRange) { store.zoomRange = zoomRange }

        .addInfoBarItems {
          InfoItems(zoomRange)
        }

    } else {
      Text(
        """
        Viewport Rect or Zoom Range missing from environment.
        \(viewportRect.debugDescription), \(zoomRange.debugDescription)
        """)
    }
  }
}

extension CanvasView {
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
        // TODO: This was determined to add "Optional(...)", find way to
        // improve rendering of ClosedRange types
        value: "\(zoomRange.lowerBound)...\(zoomRange.upperBound)"
      )
    }
  }
}
