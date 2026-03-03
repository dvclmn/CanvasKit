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
  @Environment(\.canvasGeometry) private var canvasGeometry
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
    CanvasMain()
      .environment(\.canvasSize, Size<CanvasSpace>(fromCGSize: canvasSize))
  }
}

extension CanvasView {

  @ViewBuilder
  private func CanvasMain() -> some View {
    
    if let canvasGeometry, let zoomRange {

      CanvasCoreView(content: content)
        .environment(store)

        .task(id: canvasGeometry) { store.geometry = canvasGeometry }
        .task(id: zoomRange) { store.zoomRange = zoomRange }

        .addInfoBarItems {
          InfoItems(zoomRange)
        }

    } else {
      Text(
        """
        Canvas Geometry or Zoom Range missing from environment.
        \(viewportRect.debugDescription), \(zoomRange.debugDescription)
        """
      )
    }
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
