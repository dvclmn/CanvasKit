//
//  GesturePhase.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 9/1/2026.
//

import SwiftUI

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

  /// `any` is only found in NSTouch, not NSEvent
  /// Not sure if useful here.
  //  case any

  /// `moved` and `touching` are aliases in NSTouch terms
  public static let moved: Self = .changed
  public static let touching: Self = .mayBegin
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

  public init(fromHover hoverPhase: HoverPhase) {
    self =
      switch hoverPhase {
        case .active: .changed
        case .ended: .ended
      }
  }
}
