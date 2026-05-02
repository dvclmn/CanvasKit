//
//  CanvasContentView.swift
//  BaseComponents
//
//  Created by Dave Coleman on 6/8/2025.
//

import GeometryPrimitives
import SwiftUI

struct CanvasCoreView<Content: View>: View {
  @Environment(CanvasHandler.self) private var store
  @Environment(\.canvasBackground) private var canvasBackground
  @Environment(\.canvasAnchor) private var canvasAnchor
  @Environment(\.zoomRange) private var zoomRange

  let canvasSize: Size<CanvasSpace>
  @Binding var transform: TransformState

  @ViewBuilder var content: () -> Content

  var body: some View {
    Color.clear
      .contentShape(Rectangle())
      .overlay {
        CanvasArtwork(
          canvasSize: canvasSize,
          transform: transform,
          content: content,
        )
        .allowsHitTesting(false)
      }
      .frame(
        maxWidth: .infinity,
        maxHeight: .infinity,
        alignment: canvasAnchor.toAlignment,
      )
      .background(canvasBackground)
      .drawingGroup(opaque: true)
      //      .ignoresSafeArea(edges: .top)

      /// View now covers full width/height provided to it, no longer
      /// cares about pan zoom etc, so is considered `ScreenSpace`
      .coordinateSpace(.named(ScreenSpace.screen))

      /// This resolves the `CanvasSpace`
      .overlayPreferenceValue(
        ArtworkBoundsAnchorKey.self,
        alignment: canvasAnchor.toAlignment,
      ) { FrameCaptureView($0) }
  }
}

extension CanvasCoreView {
  @ViewBuilder
  private func FrameCaptureView(_ anchor: Anchor<CGRect>?) -> some View {
    Color.clear
      .allowsHitTesting(false)
      .onGeometryChange(for: CGRect?.self) { proxy in
        anchor.map { proxy[$0] }
      } action: { frame in
        let frameResult = frame.map { Rect<ScreenSpace>(fromRect: $0) }
        store.artworkFrame = frameResult
      }
  }
}
