//
//  CanvasContentView.swift
//  BaseComponents
//
//  Created by Dave Coleman on 6/8/2025.
//

import InteractionKit
import InteractionKit
import SwiftUI

struct CanvasCoreView<Content: View>: View {
  @Environment(CanvasInteractionState.self) private var interactionState
  @Environment(\.canvasBackground) private var canvasBackground

  let canvasSize: Size<CanvasSpace>
  @ViewBuilder var content: () -> Content

  var body: some View {
    Color.clear
      .overlay {
        CanvasArtwork(canvasSize: canvasSize, content: content)
        // TODO: Need to bring back the GridFont modifier.
        // Maybe expose an additional Viewbuilder closure for
        // targeting the Artwork itself?
        //          .gridFont(for: .canvas)
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

      .modifier(InteractionModifiers())
  }
}

extension CanvasCoreView {
  @ViewBuilder
  private func ArtworkGeometry(_ anchor: Anchor<CGRect>?) -> some View {
    GeometryReader { proxy in
      let frame = anchor.map { proxy[$0] }
      Color.clear
        .allowsHitTesting(false)
        .task(id: frame) {
          let frameRect = frame.map { Rect<ScreenSpace>(fromRect: $0) }
          interactionState.updateArtworkFrame(to: frameRect)
        }
    }
  }
}
