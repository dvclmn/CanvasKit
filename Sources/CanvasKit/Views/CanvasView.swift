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
  @Environment(\.viewportRect) private var viewportRect
  @Environment(\.canvasAnchor) private var canvasAnchor
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.shouldShowInfoBarItems) private var shouldShowInfoBarItems
  @Environment(\.canvasGeometry) private var canvasGeometry

  @State var store = CanvasHandler()
  @State private var canvasFrame: Rect<ScreenSpace>?

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
      
      .environment(\.artworkFrameInViewport, canvasFrame)
      .coordinateSpace(.named(ScreenSpace.screen))
//      .onGeometryChange(for: Rect<ScreenSpace>.self) { proxy in
//        let frame = proxy[]
//      } action: { newValue in
//        <#code#>
//      }
      .overlayPreferenceValue(ArtworkBoundsAnchorKey.self) { anchor in
        GeometryReader { proxy in
          let frame = anchor.map { proxy[$0] }
          Color.clear
            .allowsHitTesting(false)
            .task(id: frame) {
              //              canvasFrame = frame
              canvasFrame = frame.map { Rect<ScreenSpace>(fromRect: $0) }
            }
        }
      }
    
      /// This is passed in via the CanvasView initialiser. Adding it to the Env here.
      .environment(\.canvasSize, canvasSize)

      .overlay {
        Text("Local canvas frame: \(String(describing: canvasFrame))")
      }
    
      .task(id: zoomRange) {
        store.zoomRange = zoomRange
        interactionState.zoomRange = zoomRange?.toCGFloatRange
      }
      //      .task(id: canvasSize) { store.canvasSize = canvasSize }
      .task(id: canvasGeometry) { interactionState.geometry = canvasGeometry }

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
