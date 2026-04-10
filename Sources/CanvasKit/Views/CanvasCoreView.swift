//
//  CanvasContentView.swift
//  BaseComponents
//
//  Created by Dave Coleman on 6/8/2025.
//

import BasePrimitives
import InteractionKit
import SwiftUI

struct CanvasCoreView<Content: View>: View {
  @Environment(CanvasHandler.self) private var store
  @Environment(\.canvasBackground) private var canvasBackground
  @Environment(\.zoomLevel) private var zoomLevel
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.zoomClamped) private var zoomClamped
  
  /// Internal Env values
//  @Environment(\.transform) private var transform
//  @Environment(\.canvasSize) private var canvasSize
  

  let canvasSize: Size<CanvasSpace>
  @Binding var transform: TransformState
  
  @ViewBuilder var content: () -> Content

  var body: some View {
    Color.clear
      .overlay {
        CanvasArtwork(canvasSize: canvasSize, content: content)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(canvasBackground)
      .drawingGroup(opaque: true)
      .allowsHitTesting(false)
      //      .ignoresSafeArea(edges: .top)

      /// View now covers full width/height provided to it,
      /// so is considered `ScreenSpace`
      .coordinateSpace(.named(ScreenSpace.screen))

      /// This resolves the `CanvasSpace`
      .overlayPreferenceValue(ArtworkBoundsAnchorKey.self) { anchor in
        Color.clear
          .allowsHitTesting(false)
          .onGeometryChange(for: CGRect?.self) { proxy in
            anchor.map { proxy[$0] }
          } action: { frame in
            let artworkFrame = frame.map { Rect<ScreenSpace>(fromRect: $0) }
            store.updateArtworkFrame(to: artworkFrame)
          }
      }

      /// Holds user input modifiers, `onSwipeGesture`, `onTapGesture`, etc

//      .debugTextOverlay(alignment: .bottomTrailing) {
//        Indented("Zoom") {
//          Labeled("Zoom", value: store.transform.scale)
//          Labeled("Zoom (Env)", value: zoomLevel)
//          Labeled("Clamped", value: zoomClamped)
//          Labeled("Range", value: zoomRange)
//        }
//      }
      .gestureModifiers()
  }
}
