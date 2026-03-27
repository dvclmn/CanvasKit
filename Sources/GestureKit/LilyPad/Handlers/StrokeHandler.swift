//
//  TouchesHandler.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 19/1/2026.
//

import SwiftUI

public typealias Strokes = [Stroke: StrokeConfig]

public struct DrawingData: Codable, Sendable {
  public var active: Stroke?
  public var phase: InteractionPhase = .none
  public var strokes: Strokes = [:]

  enum CodingKeys: CodingKey {
    case strokes
  }

  public init() {}
}

extension DrawingData {
  public var pointCount: Int {
    strokes.reduce(into: 0) { partialResult, dict in
      partialResult += dict.key.points.count
    }
  }
  public var strokeCount: Int { strokes.count }
}
