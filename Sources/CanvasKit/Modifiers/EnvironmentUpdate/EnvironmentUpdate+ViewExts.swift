//
//  EnvironmentUpdate+ViewExts.swift
//  CanvasKit
//
//  Created by Dave Coleman on 5/5/2026.
//

import SwiftUI

extension View {
  /// Adds the current canvas transform values to the environment.
  public func updateTransformEnvironment() -> some View {
    self.modifier(TransformStateEnvironmentModifier())
  }

  /// Adds the current mapped pointer values to the environment.
  public func updatePointerEnvironment(
    in resolvedSize: Size<CanvasSpace>
  ) -> some View {
    self.modifier(
      PointerStateEnvironmentModifier(
        resolvedSize: resolvedSize
      )
    )
  }
}
