//
//  CanvasSnapshot.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 17/3/2026.
//

//import InteractionKit
import BasePrimitives
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

  let artworkFrame: Rect<ScreenSpace>?

  /// ## Pointer state
  let pointerTap: Point<CanvasSpace>?
  let pointerDrag: Rect<CanvasSpace>?
  let pointerHover: Point<CanvasSpace>?
  let isPointerInsideCanvas: Bool

  /// Phase of any in-progress gesture
  let phase: InteractionPhase
}

struct CanvasSnapshotModifier: ViewModifier {

  let snapshot: CanvasSnapshot?
  func body(content: Content) -> some View {
    content
      .environment(\.zoomLevel, snapshot?.zoom ?? 1.0)
      .environment(\.panOffset, snapshot?.pan.cgSize ?? .zero)
      .environment(\.rotation, snapshot?.rotation ?? .zero)

      .environment(\.pointerTap, snapshot?.pointerTap)
      .environment(\.pointerDrag, snapshot?.pointerDrag)
      .environment(\.pointerHover, snapshot?.pointerHover)

      .environment(\.artworkFrameInViewport, snapshot?.artworkFrame)
      .environment(\.interactionPhase, snapshot?.phase ?? .none)
  }
}

extension View {
  func setSnapshotValues(_ snapshot: CanvasSnapshot?) -> some View {
    self.modifier(CanvasSnapshotModifier(snapshot: snapshot))
  }
}
