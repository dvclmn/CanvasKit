//
//  InteractionSource.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 16/3/2026.
//

import SwiftUI

/// The raw input source from a SwiftUI gesture modifier.
///
/// Each case maps 1:1 to a concrete gesture modifier in `InteractionModifiers`:
/// - `.swipeGesture` —> `.onSwipeGesture(isEnabled:_:)`
/// - `.pinchGesture` —> `.onPinchGesture(initial:isEnabled:didUpdateZoom:)`
/// - `.continuousHover` —> `.onContinuousHover(coordinateSpace:perform:)`
/// - `.pointerTapGesture` —> `.onTapGesture(count:coordinateSpace:perform:)`
/// - `.pointerDragGesture` —> `.onPointerDragGesture(rect:coordinateSpace:...)`
///
/// Under two-tier resolution:
/// - Swipe, pinch, and hover are handled globally by `CanvasInteractionState`
/// - Pointer tap and drag are forwarded to the active `CanvasTool.resolve()`

public enum InteractionSource: Sendable {
  case swipeGesture(
    delta: Size<ScreenSpace>,
    location: Point<ScreenSpace>
  )
  /// Scale expected to already be clamped
  case pinchGesture(scale: Double)
  // case rotation (not yet implemented)
  case continuousHover(Point<ScreenSpace>)
  case pointerTapGesture(
    PointerButton = .primary,
    location: Point<ScreenSpace>
  )
  case pointerDragGesture(PointerDragPayload)
  //  case pointerDragGesture(
  //    delta: Size<ScreenSpace>,
  //    location: Point<ScreenSpace>
  //  )
  //  case pointerDragGesture(
  //    from: Point<ScreenSpace>,
  //    current: Point<ScreenSpace>
  //  )
}

extension InteractionSource {
  public var name: String {
    switch self {
      case .swipeGesture(let delta, let location): "Swipe[delta: \(formatSize(delta)), location: \(formatPoint(location))]"
      case .pinchGesture(let scale): "Pinch[scale: \(scale.displayString(.concise))]"
      case .continuousHover(let point): "Hover[point: \(formatPoint(point))]"
      case .pointerTapGesture(let pointerButton, let location): "Tap[button: \(pointerButton.rawValue), location: \(formatPoint(location))]"
      case .pointerDragGesture(let pointerDragPayload): "Drag[payload: \(pointerDragPayload.name)]"
    }
  }
  
  private func formatSize(_ value: Size<ScreenSpace>) -> String {
    value.cgSize.displayString(formatPreset)
  }
  private func formatPoint(_ value: Point<ScreenSpace>) -> String {
    value.cgPoint.displayString(formatPreset)
  }
  private var formatPreset: FloatDisplayPreset { .concise }

}

public enum PointerButton: String, Sendable {
  case primary
  case secondary
  case middle
}
