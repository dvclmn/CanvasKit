//
//  CanvasSurfaceView.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 28/2/2026.
//

import BasePrimitives
import SwiftUI

struct CanvasArtwork<Content: View>: View {
  @Environment(CanvasHandler.self) private var store
  @Environment(CanvasInteraction.self) private var interactionState
  @Environment(\.zoomLevel) private var zoomLevel
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.zoomClamped) private var zoomClamped
  @Environment(\.canvasBackground) private var canvasBackground
//  @Environment(\.transformState) private var transformState
  @Environment(\.canvasSize) private var canvasSize

  @ViewBuilder var content: () -> Content

  var body: some View {
    canvasDecomposed
      .frame(
        width: canvasSize?.width,
        height: canvasSize?.height
      )
      .coordinateSpace(.named(CanvasSpace.artwork))
      .anchorPreference(key: ArtworkBoundsAnchorKey.self, value: .bounds) { $0 }
    
      .scaleEffect(zoomClamped)
      .offset(interactionState.transform.panState.pan)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    /// Hit testing, background and drawing group are all handled in Canvas Core view

  }
}

extension CanvasArtwork {

  /// This allows Views to specifcy whether they should be clipped
  /// by the Canvas bounds or not
  @ViewBuilder
  private var canvasDecomposed: some View {
    if #available(macOS 15.0, iOS 18.0, *) {
      Group(subviews: content()) { subviewCollection in
        ZStack {
          ForEach(subviews: subviewCollection) { subview in
            if subview.containerValues.allowsCanvasClipping {
              subview
                .clipShape(.rect(cornerRadius: cornerRounding))
            } else {
              subview
            }
          }
        }
        .overlay {
          RoundedRectangle(cornerRadius: cornerRounding)
            .fill(.clear)
            .stroke(.white.opacity(0.07), lineWidth: outlineThickness)
        }
      }
    } else {
      ZStack {
        content()
      }
      .modifier(CanvasOutlineModifier())
    }
  }

  private var cornerRounding: CGFloat {
    let base = Styles.sizeTiny
    return base.removingZoom(zoomLevel)
  }

  private var outlineThickness: CGFloat {
    let base = 1.0
    return base.removingZoom(zoomLevel, across: zoomRange)
  }
}
