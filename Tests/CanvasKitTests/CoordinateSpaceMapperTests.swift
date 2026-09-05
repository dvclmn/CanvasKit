//
//  CoordinateSpaceMapperTests.swift
//  CanvasKit
//
//  Created by Dave Coleman on 5/9/2026.
//

import Foundation
import Testing

@testable import CanvasKit

struct CoordinateSpaceMapperTests {
  // Big Blue Terminal at 28 pt has a measured cell width of 56/3 pt.
  // These local widths were reproduced in a centred SwiftUI layout at 2x display scale.
  @Test(arguments: [
    (1, 19.0), (3, 56.0), (16, 299.0), (37, 691.0),
    (80, 1493.0), (85, 1587.0), (99, 1848.0),
  ], [0.1, 0.9, 2.07, 4.5, 4.7, 10.0])
  func layoutRoundingDoesNotChangeZoom(
    artwork: (columns: Int, layoutWidth: Double),
    zoom: Double,
  ) {
    let logicalSize = Size<CanvasSpace>(width: CGFloat(artwork.columns) * 56 / 3, height: 280)
    let mapper = CoordinateSpaceMapper(
      frame: .init(x: -75, y: 30, width: artwork.layoutWidth * zoom, height: 280 * zoom),
      canvasSize: logicalSize,
      layoutSize: .init(width: artwork.layoutWidth, height: 280),
    )

    #expect(abs(mapper.zoom - zoom) < 1e-12)
    #expect(!mapper.hasNonUniformScale)
    #expect(mapper.nonUniformScaleDiagnostic == nil)
    #expect(mapper.canvasSize == logicalSize)

    let canvasPoint = Point<CanvasSpace>(x: logicalSize.width - 0.01, y: 279.99)
    let viewportPoint = Point<ViewportSpace>(
      x: -75 + canvasPoint.x * zoom,
      y: 30 + canvasPoint.y * zoom,
    )
    let mapped = mapper.canvasPoint(from: viewportPoint)
    #expect(abs(mapped.x - canvasPoint.x) < 1e-9)
    #expect(abs(mapped.y - canvasPoint.y) < 1e-9)
    #expect(mapper.isInsideCanvas(mapped))
    #expect(!mapper.isInsideCanvas(.init(x: logicalSize.width, y: 0)))
  }

  @Test func bothRoundedAxesUseMeasuredGeometryAndPreserveLogicalBounds() {
    let mapper = CoordinateSpaceMapper(
      frame: .init(x: 50, y: -20, width: 40, height: 62),
      canvasSize: .init(width: 20.25, height: 30.75),
      layoutSize: .init(width: 20, height: 31),
    )

    #expect(mapper.zoom == 2)
    #expect(!mapper.hasNonUniformScale)
    #expect(mapper.canvasPoint(from: .init(x: 70, y: 10)) == .init(x: 10, y: 15))
    #expect(mapper.screenPoint(from: .init(x: 10, y: 15)) == .init(x: 70, y: 10))
    #expect(CGPoint(x: 10, y: 15).applying(mapper.canvasToViewport) == CGPoint(x: 70, y: 10))
    #expect(CGPoint(x: 70, y: 10).applying(mapper.viewportToCanvas) == CGPoint(x: 10, y: 15))
    #expect(mapper.canvasRect(from: .init(x: 70, y: 10, width: 8, height: 12))
      == .init(x: 10, y: 15, width: 4, height: 6))
    #expect(mapper.isInsideCanvas(.init(x: 20.1, y: 30.7)))
    #expect(!mapper.isInsideCanvas(.init(x: 10, y: 30.8)))
  }

  @Test(arguments: [0.05, 0.1, 1.0, 10.0, 100.0])
  func scaleDiagnosticUsesRelativeTolerance(zoom: Double) {
    func mapper(widthScale: Double) -> CoordinateSpaceMapper {
      .init(
        frame: .init(x: 0, y: 0, width: 100 * zoom * widthScale, height: 100 * zoom),
        canvasSize: .init(width: 100, height: 100),
      )
    }

    #expect(!mapper(widthScale: 1.0005).hasNonUniformScale)
    let distorted = mapper(widthScale: 1.01)
    #expect(distorted.hasNonUniformScale)
    #expect(distorted.nonUniformScaleDiagnostic != nil)
    #expect(abs(distorted.zoom - zoom) < 1e-12)
  }

  @Test func invalidAxesDoNotInventAnIdentityScale() {
    let zeroWidth = CoordinateSpaceMapper(
      frame: .init(x: 10, y: 20, width: 0, height: 300),
      canvasSize: .init(width: 0, height: 100),
    )
    #expect(zeroWidth.zoom == 3)
    #expect(!zeroWidth.hasNonUniformScale)

    let zeroHeight = CoordinateSpaceMapper(
      frame: .init(x: 10, y: 20, width: 300, height: 0),
      canvasSize: .init(width: 100, height: 0),
    )
    #expect(zeroHeight.zoom == 3)

    let invalid = CoordinateSpaceMapper(
      frame: .init(x: 10, y: 20, width: .infinity, height: -1),
      canvasSize: .init(width: 100, height: .nan),
    )
    #expect(invalid.zoom == 1)
    #expect(invalid.nonUniformScaleDiagnostic == nil)
  }

  @Test func explicitSizeChangeWaitsForMatchingGeometry() throws {
    let originalSize = Size<CanvasSpace>(width: 298.6666666666667, height: 280)
    let replacementSize = Size<CanvasSpace>(width: 56, height: 112)
    let original = ArtworkGeometry(
      frame: .init(x: 40, y: 50, width: 598, height: 560),
      layoutSize: .init(width: 299, height: 280),
      explicitCanvasSize: originalSize,
    )

    #expect(original.coordinateSpaceMapper(for: replacementSize) == nil)
    #expect(original.coordinateSpaceMapper(for: nil) == nil)
    #expect(try #require(original.coordinateSpaceMapper(for: originalSize)).zoom == 2)

    let replacement = ArtworkGeometry(
      frame: .init(x: 100, y: 150, width: 112, height: 224),
      layoutSize: replacementSize,
      explicitCanvasSize: replacementSize,
    )
    let mapper = try #require(replacement.coordinateSpaceMapper(for: replacementSize))
    #expect(mapper.canvasSize == replacementSize)
    #expect(mapper.canvasPoint(from: .init(x: 120, y: 170)) == .init(x: 10, y: 10))
    #expect(!mapper.hasNonUniformScale)
  }

  @Test func implicitCanvasSizeUsesTheSameLayoutObservation() throws {
    let geometry = ArtworkGeometry(
      frame: .init(x: 20, y: 30, width: 300, height: 150),
      layoutSize: .init(width: 200, height: 100),
      explicitCanvasSize: nil,
    )
    let mapper = try #require(geometry.coordinateSpaceMapper(for: nil))
    #expect(mapper.canvasSize == .init(width: 200, height: 100))
    #expect(mapper.zoom == 1.5)
    #expect(geometry.coordinateSpaceMapper(for: .init(width: 200, height: 100)) == nil)
  }
}
