//
//  Handler+Resize.swift
//  BaseComponents
//
//  Created by Dave Coleman on 5/8/2025.
//

import GeometryPrimitives
//import BasePrimitives
import SwiftUI

public struct ResizeHandler {

  /// Aka domain size
  var startCanvasSize: CGSize?
  /// Represents the in-progress canvas transformation,
  /// allowing real time visual feedback, and leaving
  /// heavier work for when the resize event is complete
  var transientCanvasSize: CGSize?

  var hoveredResizePoint: UnitPoint?
  //  var hoveredResizePoint: GridBoundaryPoint?
  var draggedResizePoint: UnitPoint?
  //  var draggedResizePoint: GridBoundaryPoint?
  /// The Canvas anchor point, around which resizing is oriented
  var canvasAnchor: UnitPoint = .center
  var hitAreaThickness: CGFloat = 30
  let boundaryOffset: RectBoundaryPlacement = .centre

  /// Control Point constants
  let controlLength: CGFloat = 9
  let controlStrokeWeight: CGFloat = 1.0

  var didEndResize: ResizeOutput?
  var didChangeResize: ResizeOutput?

  public init() {}
}

extension ResizeHandler {
  mutating func triggerDidEndResize(
    _ point: UnitPoint,
    //    _ point: GridBoundaryPoint,
    _ size: CGSize,
  ) {
    didEndResize?(point, size)
  }

  mutating func triggerDidChangeResize(_ point: UnitPoint, _ size: CGSize) {
    didChangeResize?(point, size)
  }

  public var isDragging: Bool {
    transientCanvasSize != nil
  }
}

extension ResizeHandler: CustomStringConvertible {
  public var description: String {
    """
    Transient (local) size: \(transientCanvasSize, default: "nil")
    Is Dragging? \(isDragging)
    """
  }
}
