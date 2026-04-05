//
//  CanvasSnapshot.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 17/3/2026.
//

import InteractionKit
import SwiftUI

/// Computed from `Canvas​Interaction​State` + `Transform​State` + geometry.
/// Holds only already-converted/mapped, consumer-ready values
///
/// I removed this type at one point, but later realised it is useful for centralising
/// all mapping in the one place, so it's clear.
///
/// Note: `artworkFrame` is not handled in snapshot.
/// It's added to the Env in `CanvasCoreView`
struct CanvasSnapshot: Sendable {
  let pointerTap: Point<CanvasSpace>?
  let pointerLocation: Point<CanvasSpace>?
  let pointerDrag: Rect<CanvasSpace>?
  let isPointerInsideCanvas: Bool
  let artworkFrame: Rect<ScreenSpace>?
  /// There is a zoom clamped property already in the Env,
  /// so this doesn't need to come in clamped.
  let zoom: Double
  let pan: Size<ScreenSpace>
  let rotation: Angle

  let phase: InteractionPhase
}

struct CanvasSnapshotModifier: ViewModifier {

  let snapshot: CanvasSnapshot?
  func body(content: Content) -> some View {
    content
      .environment(\.pointerTap, snapshot?.pointerTap)
      .environment(\.pointerLocation, snapshot?.pointerLocation)
      .environment(\.pointerDrag, snapshot?.pointerDrag)
      .environment(\.artworkFrameInViewport, snapshot?.artworkFrame)
      .environment(\.zoomLevel, snapshot?.zoom ?? 1.0)
      .environment(\.panOffset, snapshot?.pan.cgSize ?? .zero)
      .environment(\.rotation, snapshot?.rotation ?? .zero)
      .environment(\.interactionPhase, snapshot?.phase ?? .none)
  }
}

extension View {
  func setSnapshotValues(_ snapshot: CanvasSnapshot?) -> some View {
    self.modifier(CanvasSnapshotModifier(snapshot: snapshot))
  }
}
