//
//  CanvasSurfaceView.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 28/2/2026.
//

import InteractionKit
import SwiftUI

struct CanvasArtwork<Content: View>: View {

  @Environment(CanvasInteractionState.self) private var interactionState
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.zoomClamped) private var zoomClamped
  @Environment(\.activeTool) private var activeTool
//  @Environment(\.canvasArtworkOutline) private var outline

  let canvasSize: Size<CanvasSpace>

  @ViewBuilder var content: () -> Content

  var body: some View {

    CanvasDecomposed()

      /// Visual indication of Canvas artwork bounds
      
//      .overlay {
//        RoundedRectangle(cornerRadius: cornerRounding)
//          .fill(.clear)
//          .stroke(outline.colour, lineWidth: outlineThickness)
//          .allowsHitTesting(false)
//      }
      .animation(.easeInOut(duration: 0.15)) { content in
        content.opacity(isCanvasReady ? 1.0 : 0.0)
      }

      .frame(
        width: canvasSize.width,
        height: canvasSize.height,
      )

      /// `CanvasSpace` namespace declared *before* pan/zoom applied
      .coordinateSpace(.named(CanvasSpace.canvas))

      /// Artwork bounds captured
      .anchorPreference(key: ArtworkBoundsAnchorKey.self, value: .bounds) { $0 }

      /// Important: Keep the order 1. Scale, 2. Rotate, 3. Offset
      .scaleEffect(zoomClamped, anchor: .center)
      .rotationEffect(interactionState.transform.rotation, anchor: .center)
      .offset(interactionState.transform.translation.cgSize)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

extension CanvasArtwork {

//  private var cornerRounding: CGFloat {
//    let base = outline.rounding
//    return base.removingZoom(zoomClamped)
//  }
//
//  private var outlineThickness: CGFloat {
//    let base = Double(outline.lineWidth)
//    return base.removingZoom(zoomClamped, across: zoomRange)
//  }

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

  private var isCanvasReady: Bool { zoomRange != nil && activeTool != nil }

}
