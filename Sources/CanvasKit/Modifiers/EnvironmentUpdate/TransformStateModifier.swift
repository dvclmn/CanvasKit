//
//  TransformModifier.swift
//  CanvasKit
//
//  Created by Dave Coleman on 25/4/2026.
//

import SwiftUI

/// Publishes canvas transform values into the SwiftUI environment.
///
/// Descendants can read `zoomLevel`, `panOffset`, and `rotation` without taking
/// a direct dependency on `CanvasHandler`.
public struct TransformStateEnvironmentModifier: ViewModifier {
  @Environment(CanvasHandler.self) private var store
  public func body(content: Content) -> some View {
    content
      .environment(\.zoomLevel, state.scale)
      .environment(\.panOffset, state.translation.cgSize)
      .environment(\.rotation, state.rotation)
  }
}

extension TransformStateEnvironmentModifier {
  private var state: TransformState { store.currentTransform }
}
