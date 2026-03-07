//
//  CanvasView.swift
//  LilyPad
//
//  Created by Dave Coleman on 24/6/2025.
//

import BasePrimitives
import GestureKit
import SwiftUI
import LayoutKit
//import UIPrimitives

public struct CanvasView<Content: View>: View {
  @Environment(\.viewportRect) private var viewportRect
  @Environment(\.canvasAnchor) private var canvasAnchor
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.shouldShowInfoBarItems) private var shouldShowInfoBarItems
  @Environment(\.canvasState) private var canvasState

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

    if let state = canvasState {
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

      //    .toolbar {
      //      ToolbarItem {
      //        if let zoomRange {
      //          //          Slider(value: $store.transform.zoom.value, in: zoomRange)
      //          QuickSlider("Zoom", value: $store.transform.zoomState.value, range: zoomRange)
      ////          QuickSlider("Zoom", value: $store.transform.zoomState.value, range: zoomRange)
      //
      //            .frame(minWidth: 200)
      //
      //        }
      //      }
      //
      //    }
      .environment(\.canvasSize, canvasSize)
      .bindModel(debounce: .noDebounce, $store.canvasState, to: state)
    } else {
      
    }
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
        value: store.canvasState.zoomLevel.toPercentString(
//        value: store.transform.zoomState.zoom.toPercentString(
          within: zoomRange,
          decimalPlaces: 2
        )
      )
      //      Labeled(
      //        "Zoom Range",
      //        value: "\(zoomRange.lowerBound)...\(zoomRange.upperBound)"
      //      )

      //      #if DEBUG
      //      if let comparison = store.pointerHoverMappingComparison {
      //        Labeled("Hover Drift", value: comparison.canvasDrift)
      //        Labeled("Native RT", value: comparison.nativeRoundTripError)
      //        Labeled("Legacy RT", value: comparison.legacyRoundTripError)
      //      }
      //      #endif
    }
  }
}
