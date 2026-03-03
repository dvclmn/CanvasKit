//
//  CanvasContentView.swift
//  BaseComponents
//
//  Created by Dave Coleman on 6/8/2025.
//

import CoreTools
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
      .overlay {
        if let canvasGeometry, let zoomRange {
          CanvasArtwork(content: content)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .allowsHitTesting(false)
      .background(canvasBackground)
      .drawingGroup(opaque: true)

      .panGesture(isEnabled: true) { delta, phase, _ in
        store.panGesture.updateDelta(delta, phase: phase)
      }
      .zoomGesture(
        zoom: $store.transform.zoom.value.toBindingDouble,
        isEnabled: true,
        didUpdateEvent: { event in
          store.updateZoom(using: event)
        }
      )
      .tapDragGesture(
        rect: store.dragRectBinding(),
        behavior: store.activeDragType,
        minimumDistance: store.pointerDrag.dragThreshold,
        didUpdateTap: { location in
          store.pointerTap.value = location
        }
      )
      .onContinuousHover(coordinateSpace: .global) { phase in
        store.updateHover(phase)
      }

      .environment(\.panOffset, store.panGesture.pan)
      .environment(\.zoomLevel, store.zoomClamped)
      .environment(\.pointerLocation, store.pointerHoverCanvas)

  }
}
