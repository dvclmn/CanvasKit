//
//  CanvasSnapshot.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 17/3/2026.
//

import InteractionKit
import InteractionKit
import SwiftUI

/// Computed from `Canvas​Interaction​State` + `Transform​State` + geometry.
/// Holds only already-converted, consumer-ready values
public struct CanvasSnapshot: Sendable {
  public let pointerLocation: Point<CanvasSpace>?
  public let isPointerInsideCanvas: Bool
  public let zoom: Double
  public let pan: CGSize
  public let rotation: Angle
}

struct CanvasSnapshotModifier: ViewModifier {

  let snapshot: CanvasSnapshot?
  func body(content: Content) -> some View {
    content
      .environment(\.zoomLevel, snapshot?.zoom ?? 1.0)
      .environment(\.panOffset, snapshot?.pan ?? .zero)
      .environment(\.rotation, snapshot?.rotation ?? .zero)
      .environment(\.pointerLocation, snapshot?.pointerLocation?.cgPoint)
  }
}

extension View {
  public func setSnapshotValues(_ snapshot: CanvasSnapshot?) -> some View {
    self.modifier(CanvasSnapshotModifier(snapshot: snapshot))
  }
}
