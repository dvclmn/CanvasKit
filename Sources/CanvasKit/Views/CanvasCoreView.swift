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
  @Environment(InteractionState.self) private var interactionState
  @Environment(\.canvasBackground) private var canvasBackground
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.zoomLevel) private var zoomLevel
  @Environment(\.canvasSize) private var canvasSize
  @Environment(\.canvasGeometry) private var canvasGeometry
//  @Environment(\.pointerState) private var pointerState
//  @Environment(\.transformState) private var transformState

  /// A lot of the optionals have been moved here to `CanvasCoreView`
  /// sepcifically so the 'flash' while dependancies load in (like viewportRect, unitSize etc)
  /// doesn't cause such a visual disturbance, As the canvas background etc is handled here.
  //  let canvasGeometry: CanvasGeometry?
  @ViewBuilder var content: () -> Content

  var body: some View {

    @Bindable var store = store
    @Bindable var interactionState = interactionState

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
        interactionState.transform.panState.updateDelta(delta, phase: phase)
//        transformState?.wrappedValue.panState.updateDelta(delta, phase: phase)
      }
      .zoomGesture(
        zoom: $interactionState.transform.zoomState.value.toBindingDouble,
        isEnabled: true,
        didUpdateEvent: {
          guard let canvasGeometry else {
            let newZoom = $0.magnification
            interactionState.transform.zoomState.update(newZoom, phase: $0.phase)
            return newZoom
          }
          return store.updateZoom(
            using: $0,
            interactionState: &interactionState,
            geometry: canvasGeometry,
            in: zoomRange
          )
        }
      )
      .tapDragGesture(
        rect: dragRectBinding(),
        //        rect: store.dragRectBinding(),
        behavior: store.activeDragType,
        minimumDistance: interactionState.pointer.pointerDrag.dragThreshold,
        didUpdateTap: { location in
          let newValue = store.updateTapLocation(location, zoom: zoom)
          interactionState.pointer.pointerTap.update(newValue)
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
        interactionState.pointer.pointerHover.update(newValue)
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
    interactionState.transform.zoomState.zoom.toCGFloat
  }
  //  @MainActor
  func dragRectBinding() -> Binding<CGRect?> {
    return switch store.activeDragType {
      case .marquee:
        Binding {
          interactionState.pointer.pointerDrag.value
        } set: {
          interactionState.pointer.pointerDrag.value = $0
        }

      case .continuous:
        Binding {
          interactionState.transform.panState.pan.toCGRectZeroOrigin
        } set: {
          interactionState.transform.panState.update($0?.size ?? .zero, phase: .changed)
        }

      case .none:
        .constant(nil)

    }
  }
  //  private var pointerHandler: PointerHandler? {
  //
  //  }
}
