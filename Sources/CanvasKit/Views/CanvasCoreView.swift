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

  @State private var artworkFrame: Rect<ScreenSpace>?

  let canvasSize: Size<CanvasSpace>
  @Bindable var state: CanvasState
//  @Binding var transform: TransformState
//  let transform: TransformState

  @ViewBuilder var content: () -> Content

  var body: some View {
    Color.clear
      .overlay {
        CanvasArtwork(
          canvasSize: canvasSize,
          transform: state.transform,
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
            let frameResult = frame.map { Rect<ScreenSpace>(fromRect: $0) }
            self.artworkFrame = frameResult
            state.artworkFrame = frameResult
//            transform.artworkFrame = frameResult
          }
      }

//      .environment(\.coordinateSpaceMapper, mapper)
      .modifier(
        CanvasSnapshotModifier(
          state: state,
//          transform: state.transform,
          pointer: store.pointer,
          phase: store.interactionContext?.phase ?? .none,
        )
      )
//      .debugText {
//        Indented("Artwork frame") {
//          Labeled("Offset", value: artworkFrame?.origin.cgPoint)
//          Labeled("W", value: artworkFrame?.width.displayString)
//          Labeled("H", value: artworkFrame?.height.displayString)
//        }
//
//        Indented("Canvas size") {
//          Labeled("W", value: canvasSize.width.displayString)
//          Labeled("H", value: canvasSize.height.displayString)
//        }
//
//      }
  }
}

extension CanvasCoreView {
  private var zoomClamped: Double { state.transform.scale.clamped(to: zoomRange) }
}
