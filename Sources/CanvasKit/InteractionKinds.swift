//
//  InputKinds.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 20/3/2026.
//

import Foundation

struct InteractionKinds: OptionSet, Sendable {

  public let rawValue: Int

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  static let swipe = Self(rawValue: 1 << 0)
  static let pinch = Self(rawValue: 1 << 1)
  static let rotation = Self(rawValue: 1 << 2)
  static let tap = Self(rawValue: 1 << 3)
  static let drag = Self(rawValue: 1 << 4)
  static let hover = Self(rawValue: 1 << 5)

  /// Default for `CanvasTool` input capabilities
  public static let tapAndDrag: Self = [.tap, .drag]

  public static let noToolsMode: Self = [.swipe, .pinch, .rotation]

  public static let all: Self = [
    .swipe, .pinch, .rotation, .tap, .drag, .hover,
  ]
}
