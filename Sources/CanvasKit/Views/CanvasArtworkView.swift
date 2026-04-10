//
//  CanvasSurfaceView.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 28/2/2026.
//

@_spi(Internals) import BasePrimitives
import InteractionKit
import SwiftUI

struct CanvasArtwork<Content: View>: View {

  @Environment(CanvasHandler.self) private var store
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.self) private var env
  @Environment(\.activeTool) private var activeTool
  @Environment(\.artworkOutline) private var artworkOutline

  let canvasSize: Size<CanvasSpace>
  let transform: TransformState
  @ViewBuilder var content: () -> Content

  var body: some View {

    CanvasDecomposed()

      .animation(.easeInOut(duration: 0.15)) { content in
        content.opacity(isCanvasReady ? 1.0 : 0.0)
      }

      .frame(
        width: canvasSize.width,
        height: canvasSize.height,
      )

      /// Visual indication of Canvas artwork bounds
      .areaOutline(
        colour: artworkOutline.colour,
        rounding: artworkOutline.rounding,
        lineWidth: artworkOutline.lineWidth,
      )

      /// `CanvasSpace` namespace declared *before* pan/zoom applied
      .coordinateSpace(.named(CanvasSpace.canvas))

      /// Artwork bounds captured
      .anchorPreference(key: ArtworkBoundsAnchorKey.self, value: .bounds) { $0 }

      /// Important: Keep the order 1. Scale, 2. Rotate, 3. Offset
      .scaleEffect(transform.scale.clampedIfNeeded(to: zoomRange), anchor: .center)
      .rotationEffect(transform.rotation, anchor: .center)
      .offset(transform.translation.cgSize)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

extension CanvasArtwork {
  private var isCanvasReady: Bool { zoomRange != nil && activeTool != nil }

  private var cornerRounding: CGFloat {
    artworkOutline.resolvedOutline(in: env).rounding
  }

  /// This allows Views to specifcy whether they should be clipped
  /// by the Canvas bounds or not
  @ViewBuilder
  private func CanvasDecomposed() -> some View {
    if #available(macOS 15.0, iOS 18.0, *) {
      Group(subviews: content()) { subviewCollection in
        SubViews(subviewCollection)
      }
    } else {
      ZStack {
        content()
      }
    }
  }

  @available(macOS 15.0, iOS 18.0, *)
  @ViewBuilder
  private func SubViews(_ subviews: SubviewsCollection) -> some View {
    ZStack {
      ForEach(subviews: subviews) { subview in
        if subview.containerValues.allowsCanvasClipping {
          subview
            .clipShape(.rect(cornerRadius: cornerRounding))
        } else {
          subview
        }
      }
    }
  }
}
