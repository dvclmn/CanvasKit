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
  @Environment(CanvasInteraction.self) private var interactionState
  @Environment(\.canvasBackground) private var canvasBackground
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.zoomLevel) private var zoomLevel
  @Environment(\.canvasSize) private var canvasSize
  @Environment(\.canvasGeometry) private var canvasGeometry
  @Environment(\.canvasInteractionPolicy) private var policy
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
      .panGesture(isEnabled: policy.panGestureEnabled) { delta, phase, _ in
        interactionState.transform.panState.updateDelta(delta, phase: phase)
        //        transformState?.wrappedValue.panState.updateDelta(delta, phase: phase)
      }
      .zoomGesture(
        zoom: $interactionState.transform.zoomState.value.toBindingDouble,
        isEnabled: policy.zoomGestureEnabled,
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
        behavior: policy.dragBehaviour,
        minimumDistance: interactionState.pointer.drag.dragThreshold,
        didUpdateTap: { location in
          handleTap(at: location)
        }
      )

      .onContinuousHover(coordinateSpace: .named(CanvasSpace.viewport)) { phase in
        guard policy.hoverEnabled else { return }
        handleHover(phase)
      }
  }
}

extension CanvasCoreView {
  
  func dragRectBinding() -> Binding<CGRect?> {
    switch policy.dragBehaviour {
      case .marquee:
        return Binding {
          interactionState.pointer.drag.value
        } set: {
          interactionState.pointer.drag.value = $0
        }
      case .continuous:
        return Binding {
          interactionState.transform.panState.pan.toCGRectZeroOrigin
        } set: {
          guard let size = $0?.size else { return }
          interactionState.transform.panState.update(size, phase: .changed)
        }
      case .none:
        return .constant(nil)
    }
  }

  private func handleTap(at location: CGPoint) {
    let mapped = store.mappedTapLocation(location, zoom: zoom)
    interactionState.pointer.tap.update(mapped)
  }

  private func handleHover(_ phase: HoverPhase) {
    let mapped = store.mappedHoverLocation(phase, zoom: zoom)
    interactionState.pointer.hover.update(mapped)
  }

  private var zoom: CGFloat {
    interactionState.transform.zoomState.zoom.toCGFloat
  }
}
