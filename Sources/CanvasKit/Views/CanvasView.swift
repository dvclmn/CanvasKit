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

  @State var store = CanvasHandler()

  let canvasSize: CGSize
  let showsInfoBar: Bool
  let content: () -> Content

  public init(
    canvasSize: CGSize,
    showsInfoBar: Bool = true,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.canvasSize = canvasSize
    self.showsInfoBar = showsInfoBar
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
          if showsInfoBar {
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
//      configuredCanvas(
//        viewportRect: viewportRect,
//        zoomRange: zoomRange
//      )
    } else {
      Text(
        "Viewport Rect or Zoom Range missing from environment. \(viewportRect.debugDescription), \(zoomRange.debugDescription)"
      )
    }
  }
}

//extension CanvasView {
//  @ViewBuilder
//  private func configuredCanvas(
//    viewportRect: CGRect,
//    zoomRange: ClosedRange<Double>
//  ) -> some View {
//    let canvas =
////    if showsInfoBar {
////      canvas
////    } else {
////      canvas
////    }
//  }
//}
