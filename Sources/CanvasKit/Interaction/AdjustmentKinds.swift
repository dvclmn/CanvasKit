//
//  AdjustmentKinds.swift
//  CanvasKit
//
//  Created by Dave Coleman on 12/4/2026.
//

struct AdjustmentKinds: OptionSet, Sendable {

  let rawValue: Int

  init(rawValue: Int) {
    self.rawValue = rawValue
  }

  /// Canvas transforms
  static let translation = Self(rawValue: 1 << 0)
  static let scale = Self(rawValue: 1 << 1)
  static let rotation = Self(rawValue: 1 << 2)

  static let tapLocation = Self(rawValue: 1 << 3)
  static let dragRect = Self(rawValue: 1 << 4)
  static let hoverLocation = Self(rawValue: 1 << 5)

  static let all: Self = [
    .translation, .scale, .rotation, .tapLocation, .dragRect, .hoverLocation,
  ]
}

extension AdjustmentKinds: CustomStringConvertible {
  static let debugDescriptions: [(Self, String)] = [
    (.translation, "Translation"),
    (.scale, "Scale"),
    (.rotation, "Rotation"),
    (.tapLocation, "Tap Location"),
    (.dragRect, "Drag Rect"),
    (.hoverLocation, "Hover Location"),
  ]

  public var description: String {
    let result: [String] = Self.debugDescriptions.filter { contains($0.0) }.map { $0.1 }
    let printable = result.joined(separator: ", ")

    return "\(printable)"
  }
}
