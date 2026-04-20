//
//  CanvasState.swift
//  CanvasKit
//
//  Created by Dave Coleman on 19/4/2026.
//

import BasePrimitives
import SwiftUI

@Observable
public final class CanvasState {
  public var transform: TransformState = .identity
  public var artworkFrame: Rect<ScreenSpace>?

  public init() {}
}

extension CanvasState {

  public func mapper(zoomRange: ClosedRange<Double>) -> CoordinateSpaceMapper? {
    guard let artworkFrame else { return nil }
    return .init(
      artworkFrame: artworkFrame,
      zoomClamped: transform.scale.clamped(to: zoomRange),
    )
  }
}
