//
//  CanvasSurfaceView.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 28/2/2026.
//

//import CanvasCore
import GeometryPrimitives
import SwiftUI

struct CanvasArtwork<Content: View>: View {
  @Environment(\.zoomLevel) private var zoomLevel
  @Environment(\.zoomRange) private var zoomRange
  //  @Environment(\.artworkOutline) private var artworkOutline
  @Environment(\.canvasAnchor) private var canvasAnchor

  let canvasSize: Size<CanvasSpace>
  let transform: TransformState

  let rounding: Double = 4
  let lineWidth: Double = 1

  @ViewBuilder var content: () -> Content

  var body: some View {

    ///
    CanvasDecomposed(rounding: effectiveRounding, content: content)
      //      .animation(.easeInOut(duration: 0.15)) { content in
      //        content.opacity(isCanvasReady ? 1.0 : 0.0)
      //      }

      .frame(
        width: canvasSize.width,
        height: canvasSize.height,
      )

      /// Visual indication of Canvas artwork bounds
      //      .areaOutline(
      //        colour: artworkOutline.colour,
      //        rounding: artworkOutline.rounding,
      //        lineWidth: artworkOutline.lineWidth,
      //      )
      .overlay {
        RoundedRectangle(cornerRadius: effectiveRounding)
          .fill(.clear)
          .stroke(
            Color.white.opacity(0.05),
            lineWidth: lineWidth.removingZoom(
              zoomLevel,
              across: zoomRange,
            ),
          )
          .allowsHitTesting(false)
      }

      /// `CanvasSpace` namespace declared *before* pan/zoom applied
      .coordinateSpace(.named(CanvasSpace.canvas))

      /// Artwork bounds captured
      .anchorPreference(key: ArtworkBoundsAnchorKey.self, value: .bounds) { $0 }

      /// Important: Keep the order 1. Scale, 2. Rotate, 3. Offset
      .scaleEffect(
        transform.scale.clamped(to: zoomRange)
        //        transform.scale.clampedIfNeeded(to: zoomRange),
        //        anchor: canvasAnchor,
      )
      .rotationEffect(transform.rotation, anchor: .center)
      .offset(transform.translation.cgSize)
      .frame(
        maxWidth: .infinity,
        maxHeight: .infinity,
        alignment: canvasAnchor.toAlignment,
      )
  }
}

extension CanvasArtwork {
  private var effectiveRounding: Double {
    rounding.removingZoom(
      zoomLevel,
      across: zoomRange,
    )
  }
}

// MARK: - Canvas clipping View
private struct CanvasDecomposed<Content: View>: View {
  //  @Environment(\.self) private var env
  //  @Environment(\.artworkOutline) private var artworkOutline

  let rounding: Double

  @ViewBuilder var content: () -> Content
  var body: some View {

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
}

extension CanvasDecomposed {
  @available(macOS 15.0, iOS 18.0, *)
  @ViewBuilder
  private func SubViews(_ subviews: SubviewsCollection) -> some View {
    ZStack {
      ForEach(subviews: subviews) { subview in
        if subview.containerValues.allowsCanvasClipping {
          subview
            .clipShape(.rect(cornerRadius: rounding))
        } else {
          subview

        }
      }
    }
  }

  //  private var cornerRounding: CGFloat {
  //    artworkOutline.resolvedOutline(in: env).rounding
  //  }
}
