//
//  CanvasContentView.swift
//  BaseComponents
//
//  Created by Dave Coleman on 6/8/2025.
//

import BasePrimitives
import SwiftUI

struct CanvasCoreView<Content: View>: View {
  @Environment(CanvasHandler.self) private var store
  @Environment(\.canvasBackground) private var canvasBackground
  @Environment(\.canvasAnchor) private var canvasAnchor
  @Environment(\.zoomRange) private var zoomRange
  
  @State private var artworkFrame: Rect<ScreenSpace>?

  let canvasSize: Size<CanvasSpace>
  let transform: TransformState

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
      ) { anchor in
        Color.clear
          .allowsHitTesting(false)
          .onGeometryChange(for: CGRect?.self) { proxy in
            anchor.map { proxy[$0] }
          } action: { frame in
            self.artworkFrame = frame.map { Rect<ScreenSpace>(fromRect: $0) }
//            store.updateArtworkFrame(to: artworkFrame)
          }
      }
      .modifier(
        CanvasSnapshotModifier(
          mapper: mapper,
          transform: transform,
          pointer: store.pointer,
          phase: store.interactionContext?.phase ?? .none
        )
      )
//      .setSnapshotValues(.in)
//      .setSnapshotValues(
//        store.snapshot(
//          zoomRange: zoomRange,
//          transform: localTransform,
//        )
//      )
  }
}

extension CanvasCoreView {
  private var zoomClamped: Double { transform.scale.clampedIfNeeded(to: zoomRange) }
  private var mapper: CoordinateSpaceMapper? {
    guard let artworkFrame else { return nil }
    return .init(artworkFrame: artworkFrame, zoomClamped: zoomClamped)
  }
  
}
