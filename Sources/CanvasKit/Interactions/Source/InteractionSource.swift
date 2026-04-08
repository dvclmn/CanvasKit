//
//  InteractionSource.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 16/3/2026.
//

import InteractionKit
import SwiftUI

public enum TransformInteraction {
  case translation(Size<ScreenSpace>)
  case scale(Double)
  case rotation(Angle)
}

public enum PointerInteraction {
  case tap(Point<ScreenSpace>)
  case hover(Point<ScreenSpace>)
  case drag(Rect<ScreenSpace>)

}

public enum Interaction {
  case transform(TransformInteraction)
  case pointer(PointerInteraction)
}

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

public enum InteractionSource {
  case swipe  // onSwipeGesture
  case pinch  // onPinchGesture
  case hover  // onContinuousHover
  case tap  // onTapGesture
  case drag  // onPointerDragGesture
  case rotation  // Not yet supported
}
//public enum InteractionSource: Sendable {
//  case swipeGesture(
//    delta: Size<ScreenSpace>,
//    location: Point<ScreenSpace>,
//  )
//  /// Scale expected to already be clamped
//  case pinchGesture(scale: Double)
//  // case rotation (not yet implemented)
//  case continuousHover(Point<ScreenSpace>)
//  case pointerTapGesture(
//    PointerButton = .primary,
//    location: Point<ScreenSpace>,
//  )
//  case pointerDragGesture(PointerDragPayload)
//}

//public enum PointerButton: String, Sendable {
//  case primary
//  case secondary
//  case middle
//}
