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
  //   @Environment(\.canvasSize) private var canvasSize

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
        store.updateHover(phase)
      }
      .environment(\.panOffset, store.pan)
      .environment(\.zoomLevel, store.zoomClamped)
      .environment(
        \.hoverLocation,
        isPreview
          ? CGPoint(x: 10, y: 10)
          : store.pointerHoverCanvas
      )

  }
}
