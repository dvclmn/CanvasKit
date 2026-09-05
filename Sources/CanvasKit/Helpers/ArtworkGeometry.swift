//
//  ArtworkGeometry.swift
//  CanvasKit
//
//  Created by Dave Coleman on 5/9/2026.
//

/// One layout observation, keeping both coordinate spaces and the size request
/// together. A new document size must not be paired with the previous frame.
struct ArtworkGeometry: Equatable {
  let frame: Rect<ViewportSpace>
  let layoutSize: Size<CanvasSpace>
  let explicitCanvasSize: Size<CanvasSpace>?

  var mapper: CoordinateSpaceMapper {
    .init(
      frame: frame,
      canvasSize: explicitCanvasSize ?? layoutSize,
      layoutSize: layoutSize,
    )
  }

  func coordinateSpaceMapper(for size: Size<CanvasSpace>?) -> CoordinateSpaceMapper? {
    guard size == explicitCanvasSize else { return nil }
    return mapper
  }
}
