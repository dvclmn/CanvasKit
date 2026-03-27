//
//  DeltaInteraction.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 14/3/2026.
//

import Foundation

extension ContinuousInteraction where Value == Size<ScreenSpace> {
  public mutating func updateDelta(
    _ screenDelta: CGSize,
    phase: InteractionPhase,
//    source: InteractionSource
  ) {
    let delta = Value(fromCGSize: screenDelta)
    self.value += delta
    self.phase = phase
//    self.source = source
  }
//  public func clamped<Space>(
//    to geometry: CanvasGeometry,
//    zoom: CGFloat
//  ) -> Size<Space> {
//    let artwork = geometry.canvasCGSize
//    let viewportRect = geometry.viewportRect
//    let scaledArtwork = artwork * zoom
//
//    let maxX = max((scaledArtwork.width - viewportRect.width) / 2, 0)
//    let maxY = max((scaledArtwork.height - viewportRect.height) / 2, 0)
//
//    return Size<Space>(
//      width: value.width.clamped(to: -maxX...maxX),
//      height: value.height.clamped(to: -maxY...maxY)
//    )
//  }
}
