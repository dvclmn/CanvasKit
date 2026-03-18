//
//  CanvasContentView.swift
//  BaseComponents
//
//  Created by Dave Coleman on 6/8/2025.
//

import BasePrimitives
//import GestureKit
import SwiftUI

struct CanvasCoreView<Content: View>: View {
  @Environment(CanvasHandler.self) private var store
  @Environment(\.canvasBackground) private var canvasBackground
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.canvasGeometry) private var canvasGeometry
  @Environment(\.viewportRect) private var viewportRect
  @Environment(\.artworkFrameInViewport) private var artworkFrameInViewport
  @Environment(\.canvasSize) private var canvasSize

  @State private var canvasFrame: Rect<ScreenSpace>?

  /// A lot of the optionals have been moved here to `CanvasCoreView`
  /// sepcifically so the 'flash' while dependancies load in (like viewportRect, unitSize etc)
  /// doesn't cause such a visual disturbance, As the canvas background etc is handled here.
  @ViewBuilder var content: () -> Content

  var body: some View {
    Rectangle()
      .fill(.clear)
      .overlay {
        /// Hides until geometry etc is ready
        //        if canvasGeometry != nil, zoomRange != nil {
        CanvasArtwork(content: content)
          //          .opacity(0.1)
          //          .opacity(canvasOpacity)
          /// Should probably set this up to be clearer for *non* Grid domain contexts
          .gridFont(for: .canvas)
        //        } else {
        //
        //          Text(
        //            """
        //            Canvas geometry or zoom range missing from Env.
        //            viewportRect: \(viewportRect?.displayString, default: "nil")
        //            artworkFrameInViewport: \(artworkFrameInViewport)
        //            canvasSize: \(canvasSize)
        //            """)
        //          .opacity(0.2)
        //        }

      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(canvasBackground)
      .drawingGroup(opaque: true)
      .allowsHitTesting(false)

      .ignoresSafeArea(edges: .top)

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

      .environment(\.artworkFrameInViewport, canvasFrame)
      .canvasTransformations()
  }
}
