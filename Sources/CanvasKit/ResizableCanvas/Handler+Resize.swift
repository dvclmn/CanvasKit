//
//  Handler+Resize.swift
//  BaseComponents
//
//  Created by Dave Coleman on 5/8/2025.
//


import SharedHelpers
import SwiftUI

public struct ResizeHandler {

  /// Aka domain size
  var startCanvasSize: CGSize?
  /// Represents the in-progress canvas transformation,
  /// allowing real time visual feedback, and leaving
  /// heavier work for when the resize event is complete
  var transientCanvasSize: CGSize?

  var hoveredResizePoint: GridBoundaryPoint?
  var draggedResizePoint: GridBoundaryPoint?
  /// The Canvas anchor point, around which resizing is oriented
  var canvasAnchor: UnitPoint = .center
  var hitAreaThickness: CGFloat = 30
  let boundaryOffset: RectBoundaryPlacement = .centre

  /// Control Point constants
  let controlLength: CGFloat = 9
  let controlStrokeWeight: CGFloat = 1.0
//  let controlHitArea: CGFloat = 12

  var didEndResize: ResizeOutput?
  var didChangeResize: ResizeOutput?

  public init() {
    print("Initialised `ResizeHandler` at \(Date.now.formatted(date: .omitted, time: .complete))")
  }
}
extension ResizeHandler {
  
  mutating func triggerDidEndResize(_ point: GridBoundaryPoint, _ size: CGSize) {
    didEndResize?(point, size)
  }

  mutating func triggerDidChangeResize(_ point: GridBoundaryPoint, _ size: CGSize) {
    didChangeResize?(point, size)
  }

  public var isDragging: Bool {
    return transientCanvasSize != nil
  }

}

extension ResizeHandler: CustomStringConvertible {
  public var description: String {
    return """
      Transient (local) size: \(transientCanvasSize?.displayString ?? "nil")
      Is Dragging? \(isDragging)


      """
  }
}


