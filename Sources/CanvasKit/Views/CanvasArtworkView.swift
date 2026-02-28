//
//  CanvasSurfaceView.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 28/2/2026.
//

import SwiftUI

struct CanvasArtwork<Content: View>: View {
  @Environment(CanvasHandler.self) private var store
  @ViewBuilder var content: () -> Content

  var body: some View {
    content()
      .frame(
        width: store.geometry.canvasSize.width,
        height: store.geometry.canvasSize.height
      )
      .coordinateSpace(.canvasIdentity)
      .modifier(CanvasOutlineModifier())
      .scaleEffect(store.zoomClamped)
      .offset(store.pan)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .allowsHitTesting(false)
      .drawingGroup(opaque: true)

  }
}
