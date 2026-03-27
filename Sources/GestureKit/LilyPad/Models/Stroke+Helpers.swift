//
//  Stroke+Helpers.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 20/1/2026.
//

//import VectorKit
import Foundation
import BasePrimitives

extension DrawingData {
  static func makeStrokes(
    from strokes: [Stroke]
  ) -> Strokes {
    Dictionary(uniqueKeysWithValues: strokes.map { stroke in
      (stroke, StrokeConfig())
    })
  }

  public mutating func addStrokes(_ strokes: [Stroke]) {
    let new = Self.makeStrokes(from: strokes)
    self.strokes.merge(new) { _, new in
      new
    }
  }
}
