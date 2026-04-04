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
public struct CanvasSnapshot: Sendable {
  public let pointerLocation: Point<CanvasSpace>?
  public let pointerDrag: Rect<CanvasSpace>?
  public let isPointerInsideCanvas: Bool

  /// There is a zoom clamped property already in the Env,
  /// so this doesn't need to come in clamped.
  public let zoom: Double
  public let pan: Size<ScreenSpace>
  public let rotation: Angle
  
}

struct CanvasSnapshotModifier: ViewModifier {

  let snapshot: CanvasSnapshot?
  func body(content: Content) -> some View {
    content
      .environment(\.pointerLocation, snapshot?.pointerLocation)
      .environment(\.pointerDrag, snapshot?.pointerDrag)
      .environment(\.zoomLevel, snapshot?.zoom ?? 1.0)
      .environment(\.panOffset, snapshot?.pan ?? .zero)
      .environment(\.rotation, snapshot?.rotation ?? .zero)
  }
}

extension View {
  public func setSnapshotValues(_ snapshot: CanvasSnapshot?) -> some View {
    self.modifier(CanvasSnapshotModifier(snapshot: snapshot))
  }
}
