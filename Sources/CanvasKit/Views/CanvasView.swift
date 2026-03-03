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
  @Environment(\.unitSize) private var unitSize

  @State var store = CanvasHandler()

  let canvasSize: Size<CanvasSpace>
  let content: () -> Content

  public init(
    canvasSize: CGSize,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.canvasSize = Size<CanvasSpace>(fromCGSize: canvasSize)
    self.content = content
  }

  public init(
    canvasSize: Size<CanvasSpace>,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.canvasSize = canvasSize
    self.content = content
  }

  public var body: some View {

    CanvasCoreView(canvasGeometry: canvasGeometry, content: content)
      .environment(store)

      .addInfoBarItems {
        if let zoomRange {
          InfoItems(zoomRange)
        }
      }

      //    CanvasMain()
      .environment(\.canvasSize, canvasSize)
    //      .environment(\.canvasSize, Size<CanvasSpace>(fromCGSize: canvasSize))
  }
}

extension CanvasView {

  private var canvasGeometry: CanvasGeometry? {
    guard let viewportRect else { return nil }
    //    guard let viewportRect, let canvasSize else { return nil }
    return CanvasGeometry(
      viewportRect: viewportRect,
      canvasSize: canvasSize,
      anchor: canvasAnchor
    )
  }

  //  @ViewBuilder
  //  private func CanvasMain() -> some View {
  //
  //    if let canvasGeometry, let zoomRange {
  //
  //
  //
  //    } else {
  //      Text(
  //        """
  //        Canvas Geometry or Zoom Range missing from environment.
  //        Canvas Geometry: \(canvasGeometry, default: "nil")
  //        Viewport Rect: \(viewportRect, default: "nil")
  //        Unit Size: \(unitSize, default: "nil")
  //        Zoom Range: \(zoomRange, default: "nil")
  //
  //        """
  //      )
  //      .font(.body)
  //      .foregroundStyle(.secondary)
  //      .frame(maxWidth: .infinity, maxHeight: .infinity)
  //    }
  //  }

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
