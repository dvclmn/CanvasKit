//
//  TransformModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 25/4/2026.
//

import SwiftUI

/// Publishes canvas transform values into the SwiftUI environment.
///
/// This is mainly useful when a caller owns `CanvasState` externally and wants
/// Environment  
/// `zoomLevel`, `panOffset`, and `rotation` available higher in the hierarchy
/// than `CanvasView` itself.
public struct TransformModifier: ViewModifier {
  let canvasState: CanvasState

  public func body(content: Content) -> some View {
    let snapshot = TransformSnapshot(transform: canvasState.transform)

    content
      .environment(\.zoomLevel, snapshot.zoomLevel)
      .environment(\.panOffset, snapshot.panOffset)
      .environment(\.rotation, snapshot.rotation)
  }
}

extension View {
  /// Adds the current canvas transform values to the environment.
  public func canvasTransformEnvironment(
    _ canvasState: CanvasState
  ) -> some View {
//  ) -> ModifiedContent<Self, TransformModifier> {
    self.modifier(TransformModifier(canvasState: canvasState))
  }
}
