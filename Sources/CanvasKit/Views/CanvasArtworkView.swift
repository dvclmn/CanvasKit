//
//  CanvasSurfaceView.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 28/2/2026.
//

import GeometryPrimitives
import SwiftUI

struct CanvasArtwork<Content: View>: View {
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.canvasAnchor) private var canvasAnchor

  let canvasSize: Size<CanvasSpace>
  let transform: TransformState

  let rounding: Double = 4
  let lineWidth: Double = 1

  @ViewBuilder var content: () -> Content

  var body: some View {

    CanvasArtworkDecomposed(
      rounding: effectiveRounding,
      content: content,
    )
    .frame(
      width: canvasSize.width,
      height: canvasSize.height,
    )

    /// Visual indication of Canvas artwork bounds
    .overlay { ArtworkOutline() }

    /// `CanvasSpace` namespace declared before pan/zoom applied
    .coordinateSpace(.named(CanvasSpace.canvas))

    /// Artwork bounds captured here
    .anchorPreference(key: ArtworkBoundsAnchorKey.self, value: .bounds) { $0 }

    /// Important: For transforms the order needs to be 1. Scale, 2. Rotation, 3. Offset
    .scaleEffect(transform.scale.clamped(to: zoomRange))

    /// Note: Rotation not yet supported, coming in future versions
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

  @ViewBuilder
  private func ArtworkOutline() -> some View {
    RoundedRectangle(cornerRadius: effectiveRounding)
      .fill(.clear)
      .stroke(
        .regularMaterial.opacity(0.9),
//        Color.white.opacity(0.05),
        lineWidth: lineWidth.removingZoom(
          transform.scale,
          across: zoomRange,
        ),
      )
      .allowsHitTesting(false)
  }
  private var effectiveRounding: Double {
    rounding.removingZoom(transform.scale, across: zoomRange)
  }
}
