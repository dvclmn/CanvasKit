//
//  ProgrammaticTransformTests.swift
//  CanvasKit
//
//  Created by Dave Coleman on 1/9/2026.
//

import Testing

@testable import CanvasKit

struct ProgrammaticTransformTests {

  @Test func operationsResolveToExpectedScales() throws {
    let canvas = Size<CanvasSpace>(width: 400, height: 200)
    let viewport = Size<ViewportSpace>(width: 800, height: 600)

    #expect(try #require(ZoomOperation.identity.resolvedScale(canvasSize: canvas, in: viewport)) == 1)
    #expect(try #require(ZoomOperation.zoom(1.5).resolvedScale(canvasSize: canvas, in: viewport)) == 1.5)
    #expect(try #require(ZoomOperation.fit.resolvedScale(canvasSize: canvas, in: viewport)) == 2)
    #expect(try #require(ZoomOperation.fill.resolvedScale(canvasSize: canvas, in: viewport)) == 3)
  }

  @Test func fitAndFillChooseTheConstrainedAxis() throws {
    let landscapeCanvas = Size<CanvasSpace>(width: 800, height: 200)
    let portraitViewport = Size<ViewportSpace>(width: 400, height: 600)

    #expect(try #require(ZoomOperation.fit.resolvedScale(canvasSize: landscapeCanvas, in: portraitViewport)) == 0.5)
    #expect(try #require(ZoomOperation.fill.resolvedScale(canvasSize: landscapeCanvas, in: portraitViewport)) == 3)
  }

  @Test func paddingReducesTheAvailableViewport() throws {
    let canvas = Size<CanvasSpace>(width: 400, height: 200)
    let viewport = Size<ViewportSpace>(width: 800, height: 600)

    let scale = try #require(
      ZoomOperation.fit.resolvedScale(
        canvasSize: canvas,
        in: viewport,
        padding: 100,
      )
    )

    #expect(scale == 1.5)
  }

  @Test func resolvedTransformClampsScaleAndResetsTheOtherComponents() throws {
    let transform = try #require(
      TransformState.resolved(
        .fill,
        canvasSize: .init(width: 400, height: 200),
        in: .init(width: 800, height: 600),
        zoomRange: 0.5...2,
      )
    )

    #expect(transform.scale == 2)
    #expect(transform.translation == .zero)
    #expect(transform.rotation == .zero)
  }

  @Test func fittedTransformClampsToTheLowerZoomBound() throws {
    let transform = try #require(
      TransformState.fitted(
        canvasSize: .init(width: 4_000, height: 2_000),
        in: .init(width: 800, height: 600),
        zoomRange: 0.5...10,
      )
    )

    #expect(transform.scale == 0.5)
  }

  @Test func invalidGeometryPaddingAndZoomRangesDoNotResolve() {
    let validCanvas = Size<CanvasSpace>(width: 400, height: 200)
    let validViewport = Size<ViewportSpace>(width: 800, height: 600)

    #expect(ZoomOperation.fit.resolvedScale(
      canvasSize: .init(width: 0, height: 200),
      in: validViewport,
    ) == nil)
    #expect(ZoomOperation.fit.resolvedScale(
      canvasSize: validCanvas,
      in: .init(width: .infinity, height: 600),
    ) == nil)
    #expect(ZoomOperation.fit.resolvedScale(
      canvasSize: validCanvas,
      in: validViewport,
      padding: -1,
    ) == nil)
    #expect(ZoomOperation.fit.resolvedScale(
      canvasSize: validCanvas,
      in: validViewport,
      padding: 400,
    ) == nil)
    #expect(ZoomOperation.zoom(0).resolvedScale(canvasSize: validCanvas, in: validViewport) == nil)
    #expect(TransformState.fitted(
      canvasSize: validCanvas,
      in: validViewport,
      zoomRange: 0...10,
    ) == nil)
  }
}
