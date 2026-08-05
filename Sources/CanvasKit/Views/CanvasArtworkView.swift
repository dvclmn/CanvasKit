//
//  CanvasSurfaceView.swift
//  CanvasKit
//
//  Created by Dave Coleman on 28/2/2026.
//

import SwiftUI

struct CanvasArtwork<Content: View>: View {
  @Environment(CanvasHandler.self) private var store
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.canvasAnchor) private var canvasAnchor
  @Environment(\.explicitCanvasSize) private var explicitCanvasSize

  let rounding: Double = 4
  let lineWidth: Double = 1

  @ViewBuilder var content: () -> Content

  var body: some View {

    ArtworkDecomposed(
      rounding: unZoomed(rounding),
      content: content,
    )

    .onGeometryChange(for: CGSize.self) { proxy in
      proxy.size
    } action: { newValue in
      // If an explicit size is provided by user, then there's
      // No need to measure the geometry manually
      guard explicitCanvasSize == nil else { return }
      store.measuredCanvasSize = Size<CanvasSpace>(fromCGSize: newValue)
    }

    // Visual indication of Canvas artwork bounds.
    .overlay { ArtworkOutline() }

    // `CanvasSpace` namespace declared before pan/zoom applied.
    .coordinateSpace(.named(CanvasSpace.canvas))

    // Artwork bounds captured here.
    .anchorPreference(key: ArtworkBoundsAnchorKey.self, value: .bounds) { $0 }

    // Important: For transforms the order needs to be 1. Scale, 2. Rotation, 3. Offset.
    .scaleEffect(store.currentTransform.scale.clamped(to: zoomRange))

    // Rotation is modelled but not yet wired to user input.
    .rotationEffect(store.currentTransform.rotation, anchor: .center)
    .offset(store.currentTransform.translation.cgSize)

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
    RoundedRectangle(cornerRadius: unZoomed(rounding))
      .fill(.clear)
      .stroke(
        .gray.opacity(0.2),
        lineWidth: unZoomed(lineWidth),
      )
      // The goal here is to add just a hint of the canvas artwork's
      // colour(s) in the stroke, via the material
      .stroke(
        .regularMaterial.opacity(0.2),
        lineWidth: unZoomed(lineWidth),
      )
      .allowsHitTesting(false)
  }

  private func unZoomed(_ value: Double) -> Double {
    value.removingZoom(store.currentTransform.scale, across: zoomRange)
  }

}
