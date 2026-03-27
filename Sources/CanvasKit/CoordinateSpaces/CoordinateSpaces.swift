//
//  NamedSpaces.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 28/2/2026.
//

import SwiftUI

/// For compile-time specialisation of e.g. ``Point`` like `Point<Space>`
///
/// ```
/// func toCanvas(
///   _ p: Point<ScreenSpace>,
///   context: CoordinateSpaceContext
/// ) -> Point<CanvasSpace>
///
/// func toGrid(
///   _ p: Point<CanvasSpace>,
///   unitSize: CGSize
/// ) -> GridPoint?
/// ```

public protocol CanvasCoordinateSpace: Sendable, Hashable {

  /// Convert a screen-space point into this coordinate space.
  static func convert(
    _ screenPoint: Point<ScreenSpace>,
    using mapper: CoordinateSpaceMapper
  ) -> Point<Self>

  /// Convert a screen-space rect into this coordinate space.
  static func convert(
    _ screenRect: Rect<ScreenSpace>,
    using mapper: CoordinateSpaceMapper
  ) -> Rect<Self>
}

public enum ScreenSpace: CanvasCoordinateSpace {

  /// Named coordinate space for the interactive viewport container.
  public static let screen: String = "canvasScreen"

  public static func convert(
    _ screenPoint: Point<ScreenSpace>,
    using mapper: CoordinateSpaceMapper
  ) -> Point<ScreenSpace> {
    screenPoint
  }

  public static func convert(
    _ screenRect: Rect<ScreenSpace>,
    using mapper: CoordinateSpaceMapper
  ) -> Rect<ScreenSpace> {
    screenRect
  }
}

public enum CanvasSpace: CanvasCoordinateSpace {

  /// Named coordinate space for the untransformed artwork/document container.
  /// Aka artwork.
  public static let canvas: String = "canvasArtwork"

  public static func convert(
    _ screenPoint: Point<ScreenSpace>,
    using mapper: CoordinateSpaceMapper
  ) -> Point<CanvasSpace> {
    mapper.canvasPoint(from: screenPoint)
  }

  public static func convert(
    _ screenRect: Rect<ScreenSpace>,
    using mapper: CoordinateSpaceMapper
  ) -> Rect<CanvasSpace> {
    mapper.canvasRect(from: screenRect)
  }
}

/// For `convert(_:from:to:)` and other space-switching APIs
//public enum CanvasCoordinateSpace {
//
//  /// The coordinate space of the device screen (pan and zoom applied).
//  case screen
//
//  /// The local coordinate space of the canvas artwork (no pan, no zoom).
//  case canvas
//}
