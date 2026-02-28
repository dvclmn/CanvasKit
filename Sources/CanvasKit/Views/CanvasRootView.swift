//
//  CanvasContentView.swift
//  BaseComponents
//
//  Created by Dave Coleman on 6/8/2025.
//

import SwiftUI

struct CanvasCoreView<Content: View>: View {
   @Environment(CanvasHandler.self) private var store
  // @Environment(\.viewportSize) private var viewportSize
  
  @ViewBuilder var content: Content
  
  var body: some View {
    
    Rectangle()
      .fill(.clear)
      .overlay {
        content
//        CanvasArtwork()
//        canvasLayer
      }
      .panGesture(isEnabled: true) { delta, phase, _ in
        store.panGesture.updateDelta(delta, phase: phase)
      }
      .zoomGesture(zoom: $store.zoomGesture.value.toBindingDouble, isEnabled: true)
      .tapDragGesture(
        rect: store.dragRectBinding(),
        behavior: store.activeDragType,
        minimumDistance: store.pointerDrag.dragThreshold,
        didUpdateTap: { location in
          store.pointerTap.value = location
        }
      )
      .onContinuousHover(coordinateSpace: .global) { phase in
        switch phase {
          case .active(let location):
            store.pointerHover.update(location, isActive: true)
          case .ended:
            store.pointerHover.update(nil, isActive: false)
        }
      }
      .environment(\.canvasGeometry, store.geometry)
      .environment(\.panOffset, store.pan)
      .environment(\.zoomLevel, store.zoomClamped)
      .task(id: canvasSize) { store.updateCanvasSize(canvasSize) }
      .task(id: zoomRange) { store.zoomRange = zoomRange }
    
  }
}
