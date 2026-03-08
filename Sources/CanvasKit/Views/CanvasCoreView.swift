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
  @Environment(\.zoomLevel) private var zoomLevel
  @Environment(\.canvasSize) private var canvasSize
  @Environment(\.canvasGeometry) private var canvasGeometry
  @Environment(\.pointerState) private var pointerState
  @Environment(\.transformState) private var transformState

  /// A lot of the optionals have been moved here to `CanvasCoreView`
  /// sepcifically so the 'flash' while dependancies load in (like viewportRect, unitSize etc)
  /// doesn't cause such a visual disturbance, As the canvas background etc is handled here.
  //  let canvasGeometry: CanvasGeometry?
  @ViewBuilder var content: () -> Content

  var body: some View {

    @Bindable var store = store

    Rectangle()
      .fill(.clear)
      .overlay {
        /// Hides until geometry etc is ready
        if canvasGeometry != nil, zoomRange != nil {
          CanvasArtwork(content: content)

            /// Should probably set this up to be clearer for *non*
            /// Grid domain contexts
            .gridFont(for: .canvas)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(canvasBackground, ignoresSafeAreaEdges: .top)
      .drawingGroup(opaque: true)
      .allowsHitTesting(false)

      .ignoresSafeArea(edges: .top)

      .coordinateSpace(.named(CanvasSpace.viewport))
      //      .prefer
      .overlayPreferenceValue(ArtworkBoundsAnchorKey.self) { anchor in
        GeometryReader { proxy in
          let frame = anchor.map { proxy[$0] }
          Color.clear
            .allowsHitTesting(false)
            .task(id: frame) {
              store.canvasFrameInViewport = frame
            }

        }
      }
      .panGesture(isEnabled: true) { delta, phase, _ in
        transformState?.wrappedValue.panState.updateDelta(delta, phase: phase)
      }
      .zoomGesture(
        zoom: transformState?.zoomState.value.toBindingDouble ?? .constant(1),
        //        zoom: $store.transform.zoomState.value.toBindingDouble,
        isEnabled: true,
        didUpdateEvent: {
//          guard let canvasGeometry else { return nil }
          let newZoom = $0.magnification
          transformState?.wrappedValue.zoomState.update($0.magnification, phase: .ended)
          return newZoom
          //return
          //          return
          //          return store.updateZoom(using: $0, geometry: canvasGeometry, in: zoomRange)
        }
      )
      .tapDragGesture(
        rect: dragRectBinding(),
        //        rect: store.dragRectBinding(),
        behavior: store.activeDragType,
        minimumDistance: pointerState?.wrappedValue.pointerDrag.dragThreshold ?? 2,
        didUpdateTap: { location in
          let newValue = store.updateTapLocation(location, zoom: zoom)
          pointerState?.wrappedValue.pointerTap.update(newValue)
          //          store.updateTapLocation(location, zoom: transformState?.wrappedValue.zoomState.zoom.toCGFloat)
          //          pointerState?.wrappedValue.pointerTap.update(
          //            pointerHandler?.canvasPoint(fromViewportPoint: location))
          //          store.pointer.pointerTap.value = store.canvasPoint(fromViewportPoint: location)
        }
      )
      //      .environment(\.panOffset, store.transform.panState.pan)
      //      .environment(\.zoomLevel, store.zoomClamped)
      //      .environment(\.pointerLocation, store.pointerHoverCanvas)

      .onContinuousHover(coordinateSpace: .named(CanvasSpace.viewport)) { phase in
        let newValue = store.updateHoverLocation(phase, zoom: zoom)
        pointerState?.wrappedValue.pointerHover.update(newValue)
        //        transformState?.wrappedValue.panState.u
        //        store.updatePointerLocation(phase)
        //        store.pointer.pointerHover.update(phase)
        //        store.updateHover(phase)
      }

    //      .environment(\.pointerLocation, store.pointerHoverCanvasIfInside)

  }
}

extension CanvasCoreView {

  private var zoom: CGFloat {
    transformState?.wrappedValue.zoomState.zoom.toCGFloat ?? 1.0
  }
  //  @MainActor
  func dragRectBinding() -> Binding<CGRect?> {
    return switch store.activeDragType {
      case .marquee:
        Binding {
          pointerState?.wrappedValue.pointerDrag.value
        } set: {
          pointerState?.wrappedValue.pointerDrag.value = $0
        }

      case .continuous:
        Binding {
          transformState?.wrappedValue.panState.pan.toCGRectZeroOrigin
        } set: {
          transformState?.wrappedValue.panState.update($0?.size ?? .zero, phase: .changed)
        }

      case .none:
        .constant(nil)

    }
  }
  //  private var pointerHandler: PointerHandler? {
  //
  //  }
}
