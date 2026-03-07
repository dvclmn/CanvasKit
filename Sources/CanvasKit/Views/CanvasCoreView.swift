//
//  CanvasContentView.swift
//  BaseComponents
//
//  Created by Dave Coleman on 6/8/2025.
//

import BasePrimitives
import GestureKit
import SwiftUI

struct CanvasCoreView<Content: View>: View {
  @Environment(CanvasHandler.self) private var store
  @Environment(\.canvasBackground) private var canvasBackground
  @Environment(\.zoomRange) private var zoomRange

  /// A lot of the optionals have been moved here to `CanvasCoreView`
  /// sepcifically so the 'flash' while dependancies load in (like viewportRect, unitSize etc)
  /// doesn't cause such a visual disturbance, As the canvas background etc is handled here.
  let canvasGeometry: CanvasGeometry?
  @ViewBuilder var content: () -> Content

  var body: some View {

    @Bindable var store = store

    Rectangle()
      .fill(.clear)
      //      .environment(\.pointerLocation, store.pointerHoverCanvas)
      .overlay {
        if canvasGeometry != nil, zoomRange != nil {
          CanvasArtwork(content: content)

            /// Should probably set this up to be clearer for *non*
            /// Grid domain contexts
            .gridFont(for: .canvas)
          //          Text("\(store.pointerHoverCanvas)")
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .allowsHitTesting(false)

      /// This background is only visible if the Artwork view
      //      .background(.orange, ignoresSafeAreaEdges: .top)
      .background(canvasBackground, ignoresSafeAreaEdges: .top)
      .drawingGroup(opaque: true)

      .ignoresSafeArea(edges: .top)
      .coordinateSpace(.named(CanvasSpace.viewport))
      .overlayPreferenceValue(CanvasArtworkBoundsAnchorKey.self) { anchor in
        GeometryReader { proxy in
          let frame = anchor.map { proxy[$0] }
          Color.clear
            .allowsHitTesting(false)
            .onAppear {
              store.artworkFrameInViewport = frame
            }
            .onChange(of: frame) { _, newValue in
              store.artworkFrameInViewport = newValue
            }
        }
      }
      .panGesture(isEnabled: true) { delta, phase, _ in
        store.state.transform.panState.updateDelta(delta, phase: phase)
      }
      .zoomGesture(
        zoom: $store.state.transform.zoomState.value.toBindingDouble,
        isEnabled: true,
        didUpdateEvent: { event in
          store.updateZoom(using: event)
        }
      )
      .tapDragGesture(
        rect: store.dragRectBinding(),
        behavior: store.activeDragType,
        minimumDistance: store.state.pointer.pointerDrag.dragThreshold,
        didUpdateTap: { location in
          store.state.pointer.pointerTap.value = store.canvasPoint(fromViewportPoint: location)
        }
      )
      //      .environment(\.panOffset, store.transform.panState.pan)
      //      .environment(\.zoomLevel, store.zoomClamped)
      //      .environment(\.pointerLocation, store.pointerHoverCanvas)

      .onContinuousHover(coordinateSpace: .named(CanvasSpace.viewport)) { phase in
        store.updateHover(phase)
      }

    //      .environment(\.pointerLocation, store.pointerHoverCanvasIfInside)

  }
}
