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

  /// A lot of the optionals have been moved here to `CanvasCoreView`
  /// sepcifically so the 'flash' while dependancies load in (like viewportRect, unitSize etc)
  /// doesn't cause such a visual disturbance, As the canvas background etc is handled here.
  @ViewBuilder var content: () -> Content

  var body: some View {
    Rectangle()
      .fill(.clear)
      .overlay {
        /// Hides until geometry etc is ready
        if canvasGeometry != nil, zoomRange != nil {
          CanvasArtwork(content: content)

            /// Should probably set this up to be clearer for *non* Grid domain contexts
            .gridFont(for: .canvas)
        } else {

          Text(
            """
            Canvas geometry or zoom range missing from Env.
            viewportRect: \(viewportRect?.displayString, default: "nil")
            artworkFrameInViewport: \(artworkFrameInViewport)
            canvasSize: \(canvasSize)
            """)
          .opacity(0.2)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(canvasBackground)
      .drawingGroup(opaque: true)
      .allowsHitTesting(false)

      .ignoresSafeArea(edges: .top)

      .canvasTransformations()
  }
}
