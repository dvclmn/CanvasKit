//
//  AdjustmentKinds.swift
//  CanvasKit
//
//  Created by Dave Coleman on 12/4/2026.
//

public enum AdjustmentKind: CaseIterable, Hashable, Sendable {
  case translation
  case scale
  case rotation
  case tapLocation
  case dragRect
  case hoverLocation

  var displayName: String {
    switch self {
      case .translation: "Translation"
      case .scale: "Scale"
      case .rotation: "Rotation"
      case .tapLocation: "Tap Location"
      case .dragRect: "Drag Rect"
      case .hoverLocation: "Hover Location"
    }
  }

  var asSet: Set {
    switch self {
      case .translation: .translation
      case .scale: .scale
      case .rotation: .rotation
      case .tapLocation: .tapLocation
      case .dragRect: .dragRect
      case .hoverLocation: .hoverLocation
    }
  }
}

// MARK: - Set
extension AdjustmentKind {
  struct Set: OptionSet, Sendable {
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
}

extension AdjustmentKind.Set {
  init(_ kind: AdjustmentKind) {
    self = kind.asSet
  }

  init<S: Sequence>(_ kinds: S) where S.Element == AdjustmentKind {
    self = kinds.reduce(into: []) { $0.formUnion($1.asSet) }
  }

  func contains(_ kind: AdjustmentKind) -> Bool {
    contains(kind.asSet)
  }

  var kinds: [AdjustmentKind] {
    AdjustmentKind.allCases.filter(self.contains)
  }
}

//extension AdjustmentKind.Set {
//  var kinds: [AdjustmentKind] {
//    AdjustmentKind.allCases.enumerated().compactMap { (index, kind) in
//      let bit = Self(rawValue: 1 << index)
//      return contains(bit) ? kind : nil
//    }
//  }
//}

extension AdjustmentKind.Set: CustomStringConvertible {
  public var description: String {
    kinds.map { $0.displayName }.joined(separator: ", ")
  }
}
