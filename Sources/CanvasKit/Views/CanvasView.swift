//
//  CanvasView.swift
//  LilyPad
//
//  Created by Dave Coleman on 24/6/2025.
//

import BasePrimitives
import SwiftUI

public struct CanvasView<Content: View>: View {
  @Environment(CanvasInteractionState.self) private var interactionState
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.shouldShowInfoBarItems) private var shouldShowInfoBarItems
  //  @Environment(\.canvasGeometry) private var canvasGeometry

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

    CanvasCoreView(content: content)

//      .addInfoBarItems {
//        if let zoomRange {
//          InfoItems(zoomRange)
//        }
//      }
      .environment(store)

//      .toolbar { CanvasToolbarView() }

      /// This is passed in via the CanvasView initialiser. Adding it to the Env here.
      .environment(\.canvasSize, canvasSize)

      .task(id: zoomRange) {
        store.zoomRange = zoomRange
        interactionState.zoomRange = zoomRange
      }

  }
}

//extension CanvasView {
//
//  @DisplayStringBuilder
//  private func InfoItems(
//    _ zoomRange: ClosedRange<Double>
//  ) -> [DisplayBlock] {
//    if shouldShowInfoBarItems {
//
//      Labeled(
//        "Zoom",
//        value: interactionState.transform.zoom.value
//          .toPercentString(within: zoomRange.toCGFloatRange)
//      )
//
//    }
//  }
//}
