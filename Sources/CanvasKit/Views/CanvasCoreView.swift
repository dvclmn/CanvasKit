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

  @ViewBuilder var content: () -> Content

  var body: some View {

    @Bindable var store = store

    Rectangle()
      .fill(.clear)
      .overlay {
        CanvasArtwork(content: content)
      }
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
      .environment(\.panOffset, store.pan)
      .environment(\.zoomLevel, store.zoomClamped)
      .environment(
        \.hoverLocation,
        (isPreview && store.pointerHoverCanvas == nil)
          ? CGPoint(x: 10, y: 10)
          : store.pointerHoverCanvas
      )

  }
}
