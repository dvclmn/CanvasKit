//
//  CanvasContentView.swift
//  BaseComponents
//
//  Created by Dave Coleman on 6/8/2025.
//

//import BasePrimitives
import SwiftUI

struct CanvasCoreView<Content: View>: View {
  @Environment(\.canvasBackground) private var canvasBackground

  @State private var canvasFrame: Rect<ScreenSpace>?

  @ViewBuilder var content: () -> Content

  var body: some View {
    Color.clear
      .overlay {
        CanvasArtwork(content: content)
          /// Should probably set this up to be clearer for *non* Grid domain contexts
          .gridFont(for: .canvas)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(canvasBackground)
      .drawingGroup(opaque: true)
      .allowsHitTesting(false)
      .ignoresSafeArea(edges: .top)
      .coordinateSpace(.named(ScreenSpace.screen))

      .overlayPreferenceValue(ArtworkBoundsAnchorKey.self) { anchor in
        ArtworkGeometry(anchor)
      }

      .environment(\.artworkFrameInViewport, canvasFrame)
      .canvasTransformations()
  }
}

extension CanvasCoreView {
  @ViewBuilder
  private func ArtworkGeometry(_ anchor: Anchor<CGRect>?) -> some View {
    GeometryReader { proxy in
      let frame = anchor.map { proxy[$0] }
      Color.clear
        .allowsHitTesting(false)
        .task(id: frame) { canvasFrame = frame.map { .init(fromRect: $0) } }
    }
  }
}
