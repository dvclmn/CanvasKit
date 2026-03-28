//
//  CanvasSurfaceView.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 28/2/2026.
//

//import BasePrimitives
import SwiftUI

struct CanvasArtwork<Content: View>: View {

  @Environment(CanvasInteractionState.self) private var interactionState
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.zoomClamped) private var zoomClamped
  @Environment(\.canvasSize) private var canvasSize
  @Environment(\.canvasGeometry) private var canvasGeometry
  @Environment(\.activeTool) private var activeTool

  @ViewBuilder var content: () -> Content

  var body: some View {
    /// Note: Hit testing, background and drawing group are all handled in Canvas Core view
    canvasDecomposed
      .animation(Styles.animationEasedQuick) { content in
        content.opacity(isCanvasReady ? 1.0 : 0.0)
      }

      .frame(
        width: canvasSize?.width,
        height: canvasSize?.height
      )
      .coordinateSpace(.named(CanvasSpace.canvas))
      .anchorPreference(key: ArtworkBoundsAnchorKey.self, value: .bounds) { $0 }
//      .scaleEffect(zoomClamped, anchor: zoomAnchor)
    /// Important note: Keep the order 1. Scale, 2. Rotate, 3. Offset
            .scaleEffect(zoomClamped, anchor: .center)
            .rotationEffect(interactionState.transform.rotation, anchor: .center)
      .offset(interactionState.transform.translation.cgSize)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .task(id: canvasGeometry) { interactionState.geometry = canvasGeometry }
  }
}

extension CanvasArtwork {

//  private var zoomAnchor: UnitPoint {
//    guard let hover = interactionState.pointer.hover?.cgPoint,
//      let size = canvasGeometry?.viewportSize
//    else { return .center }
//    return UnitPoint(point: hover, in: size)
//  }

  private var isCanvasReady: Bool {
    canvasGeometry != nil && zoomRange != nil && activeTool != nil
  }
  /// Based on whether all geometry data is ready, to display
  /// the Canvas proeperly. Note: avoiding actually *hiding*
  /// the canvas View itself, as this will prevent the geometry from
  /// even being read.

  /// This allows Views to specifcy whether they should be clipped
  /// by the Canvas bounds or not
  @ViewBuilder
  private var canvasDecomposed: some View {
    if #available(macOS 15.0, iOS 18.0, *) {
      Group(subviews: content()) { subviewCollection in
        SubViews(subviewCollection)
      }
    } else {
      ZStack {
        content()
      }
      .modifier(CanvasOutlineModifier())
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
    .overlay {
      RoundedRectangle(cornerRadius: cornerRounding)
        .fill(.clear)
        .stroke(.white.opacity(0.07), lineWidth: outlineThickness)
    }
  }

  private var cornerRounding: CGFloat {
    let base = Styles.sizeTiny
    return base.removingZoom(zoomClamped)
  }

  private var outlineThickness: CGFloat {
    let base = 1.0
    return base.removingZoom(zoomClamped, across: zoomRange)
  }
}
