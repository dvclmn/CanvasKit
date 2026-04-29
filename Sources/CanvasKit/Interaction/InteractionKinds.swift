//
//  InputKinds.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 20/3/2026.
//

// TODO: Improve wording here

/// CanvasKit supports six types of user input.
///
/// Swipe, Pinch, and Rotate are viewport gestures, performed with the trackpad.
/// By default, these are paired with ``GestureIntent``s, Pan, Zoom and Rotate.
/// They can be assigned alternative behaviours when declaring a new ``CanvasTool``.
///
/// Tap Drag, and Hover are pointer events. Their values are captured in Screen
/// Space, and can be mapped to Canvas space to allow targeting Canvas level things.
public enum InteractionKind: CaseIterable, Hashable, Sendable {
  
  // Viewport gestures
  case swipe
  case pinch
  case rotate
  
  // Pointer events
  case tap
  case drag
  case hover

  var displayName: String {
    switch self {
      case .swipe: "Swipe"
      case .pinch: "Pinch"
      case .rotate: "Rotate"
      case .tap: "Tap"
      case .drag: "Drag"
      case .hover: "Hover"
    }
  }

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

// MARK: - Set
extension InteractionKind {

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

extension InteractionKind.Set {
  init(_ kind: InteractionKind) {
    self = kind.asSet
  }

  init<S: Sequence>(_ kinds: S) where S.Element == InteractionKind {
    self = kinds.reduce(into: []) { $0.formUnion($1.asSet) }
  }

  func contains(_ kind: InteractionKind) -> Bool { contains(kind.asSet) }

  var kinds: [InteractionKind] { InteractionKind.allCases.filter(self.contains) }
}

extension InteractionKind.Set: CustomStringConvertible {
  public var description: String {
    kinds.map { $0.displayName }.joined(separator: ", ")
  }
}
