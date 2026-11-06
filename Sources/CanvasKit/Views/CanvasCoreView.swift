//
//  CanvasCoreView.swift
//  BaseComponents
//
//  Created by Dave Coleman on 6/8/2025.
//

import SwiftUI

struct CanvasCoreView<Content: View>: View {
  @Environment(\.canvasAnchor) private var canvasAnchor

  @ViewBuilder var content: () -> Content

  var body: some View {
    Color.clear
      .overlay {
        CanvasArtwork(content: content)
      }
      .frame(
        maxWidth: .infinity,
        maxHeight: .infinity,
        alignment: canvasAnchor.toAlignment,
      )
      .clipped()
      //      .ignoresSafeArea(edges: .top)

      // View now covers full width/height provided to it, no longer
      // cares about pan zoom etc, so is considered `ViewportSpace`.
      .coordinateSpace(.named(ViewportSpace.viewport))
  }
}
