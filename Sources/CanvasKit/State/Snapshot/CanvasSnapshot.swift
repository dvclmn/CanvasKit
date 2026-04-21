//
//  CanvasSnapshot.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 17/3/2026.
//

import CanvasCore
import InputPrimitives
import SwiftUI

/// Computed from `CanvasHandler` state and geometry.
/// Holds only already-converted/mapped, consumer-ready values
///
/// Note to self: I removed this type at one point, thinking it wasn't
/// doing anything useful. But soon realised its really helpful for
/// centralising fully mapped state unambiguously, well worth keeping.
struct CanvasSnapshot: Sendable {

  /// ## Transform state
  /// There is a zoom clamped property already in the Env,
  /// so this doesn't need to come in clamped.
  let zoom: Double
  let pan: Size<ScreenSpace>
  let rotation: Angle

//  let artworkFrame: Rect<ScreenSpace>?

  /// ## Pointer state
  let pointerTap: Point<CanvasSpace>?
  let pointerDrag: Rect<CanvasSpace>?
  let pointerHover: Point<CanvasSpace>?
  let isPointerInsideCanvas: Bool

  /// Phase of any in-progress gesture
  let phase: InteractionPhase
}
