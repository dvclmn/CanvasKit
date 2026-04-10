//
//  CanvasTransformState.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 1/3/2026.
//

import InteractionKit
import SwiftUI

public struct TransformState: Sendable, Equatable {
  public var translation: Size<ScreenSpace>

  /// This value is not clamped. Should be done by the caller if required
  public var scale: Double
  public var rotation: Angle

  public init(
    translation: Size<ScreenSpace> = .zero,
    scale: Double = 1.0,
    rotation: Angle = .zero,
  ) {
    self.translation = translation
    self.scale = scale
    self.rotation = rotation
  }

  public static var identity: Self { .init() }
}

extension TransformState {
  public mutating func reset() { self = Self.identity }
}
