//
//  CanvasState.swift
//  CanvasKit
//
//  Created by Dave Coleman on 19/4/2026.
//

import CoreUtilities
import GeometryPrimitives
import SwiftUI

//@Observable
//public final class CanvasState {
//  public var transform: TransformState = .identity
//  
//  /// This is updated any time pan or zoom change
//  public var artworkFrame: Rect<ScreenSpace>?
//
//  public init() {}
//}
//
//extension CanvasState {
//  public func mapper(zoomRange: ClosedRange<Double>) -> CoordinateSpaceMapper? {
//    guard let artworkFrame else { return nil }
//    return .init(
//      artworkFrame: artworkFrame,
//      zoomClamped: transform.scale.clamped(to: zoomRange),
//    )
//  }
//}
