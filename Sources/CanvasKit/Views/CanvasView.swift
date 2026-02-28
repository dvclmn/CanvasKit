//
//  CanvasView.swift
//  LilyPad
//
//  Created by Dave Coleman on 24/6/2025.
//

//import BaseUI
import CoreTools
import GestureKit
import SwiftUI

public struct CanvasView<Content: View>: View {
  @Environment(\.isDebugMode) private var isDebugMode
  @Environment(\.modifierKeys) private var modifierKeys
  @Environment(\.zoomRange) private var zoomRange
  @Environment(\.viewportRect) private var viewportRect

  //  @State private var hasZoomedToFit: Bool = false

  @State var canvasHandler = CanvasHandler()

  let canvasSize: CGSize
  let showsInfoBar: Bool
  let content: Content

  public init(
    canvasSize: CGSize,
    showsInfoBar: Bool = true,
    @ViewBuilder content: @escaping () -> Content,
  ) {
    self.canvasSize = canvasSize
    self.showsInfoBar = showsInfoBar
    self.content = content()
  }

  public var body: some View {
    if let viewportRect {
      canvasSurface
        .task(id: viewportRect) { canvasHandler.updateViewportRect(viewportRect) }
    } else {
      Text("No Viewport rect provided")
    }
  }
}

extension CanvasView {

  private var canvasSurface: some View {
    Rectangle()
      .fill(.clear)
      .overlay { canvasLayer }
      .panGesture(isEnabled: true) { delta, phase, _ in
        canvasHandler.panGesture.updateDelta(delta, phase: phase)
      }
      .zoomGesture(zoom: $canvasHandler.zoomGesture.value.toBindingDouble, isEnabled: true)
      .tapDragGesture(
        rect: canvasHandler.dragRectBinding(),
        behavior: canvasHandler.activeDragType,
        minimumDistance: canvasHandler.pointerDrag.dragThreshold,
        didUpdateTap: { location in
          canvasHandler.pointerTap.value = location
        }
      )
      .onContinuousHover(coordinateSpace: .global) { phase in
        switch phase {
          case .active(let location):
            canvasHandler.pointerHover.update(location, isActive: true)
          case .ended:
            canvasHandler.pointerHover.update(nil, isActive: false)
        }
      }
      .environment(\.canvasGeometry, canvasHandler.geometry)
      .environment(\.panOffset, canvasHandler.pan)
      .environment(\.zoomLevel, canvasHandler.zoomClamped)
      .task(id: canvasSize) { canvasHandler.updateCanvasSize(canvasSize) }
      .task(id: zoomRange) { canvasHandler.zoomRange = zoomRange }
  }

  private var canvasLayer: some View {
    content
      .frame(
        width: canvasHandler.geometry.canvasSize.width,
        height: canvasHandler.geometry.canvasSize.height
      )
      .coordinateSpace(.canvasIdentity)
      .modifier(CanvasOutlineModifier())
      .scaleEffect(canvasHandler.zoomClamped)
      .offset(canvasHandler.pan)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .allowsHitTesting(false)
      .drawingGroup(opaque: true)
  }
}
