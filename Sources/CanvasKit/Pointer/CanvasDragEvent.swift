//
//  CanvasDragEvent.swift
//  CanvasKit
//
//  Created by Dave Coleman on 20/8/2026.
//

/// An ordered marquee-drag snapshot in logical canvas coordinates.
///
/// `start` remains the gesture anchor and `current` remains the latest pointer
/// location, including for reverse-direction drags. Use ``boundingRect`` when
/// normalised geometry is needed for drawing or intersection tests.
public struct CanvasDragEvent: Sendable, Equatable {
  public let start: Point<CanvasSpace>
  public let current: Point<CanvasSpace>
  public let phase: InteractionPhase

  public init(
    start: Point<CanvasSpace>,
    current: Point<CanvasSpace>,
    phase: InteractionPhase,
  ) {
    self.start = start
    self.current = current
    self.phase = phase
  }

  /// The normalised rectangle spanning ``start`` and ``current``.
  public var boundingRect: Rect<CanvasSpace> {
    .init(from: start, to: current)
  }

  @available(*, deprecated, renamed: "boundingRect")
  public var rect: Rect<CanvasSpace> { boundingRect }
}

extension CanvasDragEvent {
  init(
    event: PointerDragEvent<ViewportSpace>,
    mapper: CoordinateSpaceMapper,
  ) {
    self.init(
      start: mapper.canvasPoint(from: event.start),
      current: mapper.canvasPoint(from: event.current),
      phase: event.phase,
    )
  }
}
