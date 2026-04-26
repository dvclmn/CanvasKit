//
//  TransformSnapshot.swift
//  CanvasKit
//
//  Created by Dave Coleman on 25/4/2026.
//

import GeometryPrimitives
import SwiftUI

/// Consumer-ready transform values derived from `TransformState`.
///
/// Internally this stays in transform language (`translation`, `scale`,
/// `rotation`). When published to the environment, those values are exposed
/// using the more canvas-specific `panOffset`, `zoomLevel`, and `rotation`.
struct TransformSnapshot: Sendable {
  let translation: Size<ScreenSpace>
  let scale: Double
  let rotation: Angle

  init(
    translation: Size<ScreenSpace>,
    scale: Double,
    rotation: Angle,
  ) {
    self.translation = translation
    self.scale = scale
    self.rotation = rotation
  }

  init(transform: TransformState) {
    self.init(
      translation: transform.translation,
      scale: transform.scale,
      rotation: transform.rotation,
    )
  }
}

extension TransformSnapshot {
  var zoomLevel: Double { scale }
  var panOffset: CGSize { translation.cgSize }
}
