//
//  GesturePhase.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 9/1/2026.
//

import AppKit
import SwiftUI

/// Based on `NSEvent.Phase`, takes cues from `NSTouch.Phase`.
///
/// Purposely omits NSTouch's `any`, as that is a mask for matching multiple
/// states, whereas `InteractionPhase` represents a single resolved phase.
/// A wildcard like `any` would be ambiguous here.
///
/// For unknown or unmappable input, use `.none`.
public enum InteractionPhase: String, Sendable, Codable {
  case began

  /// An event is in progress, but hasn't moved since the previous event.
  /// Aka, has issued `began`, and is not yet `ended` or `cancelled`
  case stationary

  case changed

  case ended
  case cancelled

  /// User has placed two fingers on trackpad.
  /// Signals the possibility of a gesture
  case mayBegin
  case none

  /// `moved` and `touching` are aliases in NSTouch terms
  /// `stationary` chosen as an alias for `NSTouch/isResting`
  public static let moved: Self = .changed

  /// In NSTouch terms, `.touching` is a mask meaning "finger is down" — a union of
  /// `.began`, `.moved`, and `.stationary`. Mapped here to `.mayBegin` as a
  /// coarse "contact present / gesture could form" signal.
  /// Use `.changed` and `.stationary` to express movement vs. no-movement.
  public static let touching: Self = .mayBegin
  public static let isResting: Self = .stationary
}

extension InteractionPhase {
  public var isActive: Bool {
    self == .began || self == .changed || self == .stationary || self == .mayBegin
  }
  public var name: String {
    switch self {
      case .mayBegin: "May Begin"
      default: rawValue.capitalized
    }
  }
}

extension InteractionPhase {

  public init(from nsEventPhase: NSEvent.Phase) {
    self =
      switch nsEventPhase {
        case .began: .began
        case .stationary: .stationary
        case .changed: .changed
        case .ended: .ended
        case .cancelled: .cancelled
        case .mayBegin: .mayBegin
        default: .none
      }
  }

  public init(from nsTouch: NSTouch) {
    if nsTouch.isResting {
      self = .stationary
    } else {
      self.init(from: nsTouch.phase)
    }
  }

  public init(from nsTouchPhase: NSTouch.Phase) {
    self =
      switch nsTouchPhase {
        case .began: .began
        case .moved: .changed
        case .stationary: .stationary
        case .ended: .ended
        case .cancelled: .cancelled
        case .touching: .mayBegin
        default: .none
      }

  }
}
