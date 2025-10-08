//
//  CanvasGesturesModifier.swift
//  BaseComponents
//
//  Created by Dave Coleman on 3/8/2025.
//

import SwiftUI
import GestureKit

public struct CanvasGesturesModifier: ViewModifier {
  
  @Binding var canvasHandler: CanvasHandler
  public func body(content: Content) -> some View {
    content
#if canImport(AppKit)
      .onPanGesture(isEnabled: true) { phase in
        //    .onPanGesture(isEnabled: canvasHandler.interactions.isInteractionAllowed(.gesturePan)) { phase in
        canvasHandler.handleGesturePanPhase(phase)
      }
      .onZoomGesture(
        zoom: $canvasHandler.zoomHandler.zoom,
        zoomRange: canvasHandler.zoomHandler.zoomRange,
        isEnabled: true
        //      isEnabled: canvasHandler.interactions.isInteractionAllowed(.gestureZoom)
      ) { phase in
        canvasHandler.handleZoom(phase)
      }
#endif
  }
}
//extension View {
//  public func example() -> some View {
//    self.modifier(CanvasGesturesModifier())
//  }
//}
