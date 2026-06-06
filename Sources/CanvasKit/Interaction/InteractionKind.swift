//
//  InputKinds.swift
//  CanvasKit
//
//  Created by Dave Coleman on 20/3/2026.
//

/// The input source for a canvas interaction.
///
/// Swipe, pinch, and rotate are viewport gestures. Tap, drag, and hover are
/// pointer events captured in viewport coordinates and, where needed, mapped
/// into ``CanvasSpace``.
extension Interaction {
  public enum Kind: CaseIterable, Hashable, Sendable {
    
    // Viewport gestures
    case swipe
    case pinch
    case rotate
    
    // Pointer events
    case tap
    case drag
    case hover
    
    var asSet: Set {
      switch self {
        case .swipe: .swipe
        case .pinch: .pinch
        case .rotate: .rotate
        case .tap: .tap
        case .drag: .drag
        case .hover: .hover
      }
    }
  }
}

extension Interaction.Kind: CustomStringConvertible {
  public var description: String {
    switch self {
      case .swipe: "Swipe"
      case .pinch: "Pinch"
      case .rotate: "Rotate"
      case .tap: "Tap"
      case .drag: "Drag"
      case .hover: "Hover"
    }

  }
}

// MARK: - Set
extension Interaction.Kind {

  struct Set: OptionSet, Sendable {
    let rawValue: Int
    init(rawValue: Int) {
      self.rawValue = rawValue
    }

    static let swipe = Self(rawValue: 1 << 0)
    static let pinch = Self(rawValue: 1 << 1)
    static let rotate = Self(rawValue: 1 << 2)
    static let tap = Self(rawValue: 1 << 3)
    static let drag = Self(rawValue: 1 << 4)
    static let hover = Self(rawValue: 1 << 5)

    static let all: Self = [
      .swipe, .pinch, .rotate, .tap, .drag, .hover,
    ]
  }
}

extension Interaction.Kind.Set {
  init(_ kind: Interaction.Kind) {
    self = kind.asSet
  }

  init<S: Sequence>(_ kinds: S) where S.Element == Interaction.Kind {
    self = kinds.reduce(into: []) { $0.formUnion($1.asSet) }
  }

  func contains(_ kind: Interaction.Kind) -> Bool { contains(kind.asSet) }

  var kinds: [Interaction.Kind] { Interaction.Kind.allCases.filter(self.contains) }
}

extension Interaction.Kind.Set: CustomStringConvertible {
  public var description: String {
    kinds.map { $0.description }.joined(separator: ", ")
  }
}
