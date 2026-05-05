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
  @Environment(CanvasHandler.self) private var store
//  let transform: TransformState

  public func body(content: Content) -> some View {
    

    content
      .environment(\.zoomLevel, snapshot.zoomLevel)
      .environment(\.panOffset, snapshot.panOffset)
      .environment(\.rotation, snapshot.rotation)
  }
}

extension TransformModifier {
  
}

extension View {
  /// Adds the current canvas transform values to the environment.
  public func canvasTransformEnvironment(
//    _ transform: TransformState
  ) -> some View {
    self.modifier(TransformModifier())
  }
}
