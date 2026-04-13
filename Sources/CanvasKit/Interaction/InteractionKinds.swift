//
//  InputKinds.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 20/3/2026.
//

import Foundation

struct InteractionKinds: OptionSet, Sendable {

  let rawValue: Int

  init(rawValue: Int) {
    self.rawValue = rawValue
  }

  static let swipe = Self(rawValue: 1 << 0)
  static let pinch = Self(rawValue: 1 << 1)
  static let rotation = Self(rawValue: 1 << 2)
  static let tap = Self(rawValue: 1 << 3)
  static let drag = Self(rawValue: 1 << 4)
  static let hover = Self(rawValue: 1 << 5)

  /// Default for `CanvasTool` input capabilities
  static let tapAndDrag: Self = [.tap, .drag]
  static let noToolsMode: Self = [.swipe, .pinch, .rotation]
  static let all: Self = [
    .swipe, .pinch, .rotation, .tap, .drag, .hover,
  ]
}

extension InteractionKinds: CustomStringConvertible {
  static let debugDescriptions: [(Self, String)] = [
    (.swipe, "Swipe"),
    (.pinch, "Pinch"),
    (.rotation, "Rotation"),
    (.tap, "Tap"),
    (.drag, "Drag"),
    (.hover, "Hover"),
  ]

  public var description: String {
    let result: [String] = Self.debugDescriptions.filter { contains($0.0) }.map { $0.1 }
    let printable = result.joined(separator: ", ")

    return "\(printable)"
  }
}
