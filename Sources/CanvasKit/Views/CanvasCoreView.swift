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

  // TODO: As I have removed CanvasState, this needs to be provided
  // somewhere else useful in CanvasKit, for mapping
  @State private var artworkFrame: Rect<ScreenSpace>?

  let canvasSize: Size<CanvasSpace>
  @Binding var transform: TransformState
//  @Bindable var state: CanvasState

  @ViewBuilder var content: () -> Content

  var body: some View {
    Color.clear
      .overlay {
        CanvasArtwork(
          canvasSize: canvasSize,
          transform: transform,
          content: content,
        )
      }
      .frame(
        maxWidth: .infinity,
        maxHeight: .infinity,
        alignment: canvasAnchor.toAlignment,
      )
      .background(canvasBackground)
      .drawingGroup(opaque: true)
      .allowsHitTesting(false)
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
        self.artworkFrame = frameResult
//        transform.artworkFrame = frameResult
      }
  }
}
