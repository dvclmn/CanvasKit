//
//  InputKinds.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 20/3/2026.
//

import Foundation

enum InteractionKind: CaseIterable {
  case swipe
  case pinch
  case rotation
  case tap
  case drag
  case hover
}

extension InteractionKind {
  var displayName: String {
    switch self {
      case .swipe: "Swipe"
      case .pinch: "Pinch"
      case .rotation: "Rotation"
      case .tap: "Tap"
      case .drag: "Drag"
      case .hover: "Hover"
    }
  }
}

// MARK: - Set
extension InteractionKind {

  struct Set: OptionSet, Sendable {

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

    static let tapAndDrag: Self = [.tap, .drag]
    static let noToolsMode: Self = [.swipe, .pinch, .rotation]
    static let all: Self = [
      .swipe, .pinch, .rotation, .tap, .drag, .hover,
    ]
  }
}

extension InteractionKind.Set {
  var kinds: [InteractionKind] {
    InteractionKind.allCases.enumerated().compactMap { (index, kind) in
      let bit = Self(rawValue: 1 << index)
      return contains(bit) ? kind : nil
    }
  }
}

extension InteractionKind.Set: CustomStringConvertible {
  public var description: String {
    kinds.map { $0.displayName }.joined(separator: ", ")
  }
}
