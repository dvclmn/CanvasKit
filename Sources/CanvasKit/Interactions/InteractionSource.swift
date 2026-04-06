//
//  InteractionSource.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 16/3/2026.
//

import SwiftUI
import InteractionKit
import InteractionKit

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
/// - Swipe, pinch, and hover are handled globally by `CanvasHandler`
/// - Pointer tap and drag are forwarded to the active `CanvasTool`
///
/// Tools can opt into additional sources via `CanvasInputCapabilities`,
/// but global handling still occurs separately.

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
}

public enum PointerButton: String, Sendable {
  case primary
  case secondary
  case middle
}
