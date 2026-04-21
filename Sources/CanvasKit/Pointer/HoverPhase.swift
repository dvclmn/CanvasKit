//
//  HoverPhase.swift
//  InteractionKit
//
//  Created by Dave Coleman on 29/3/2026.
//

import SwiftUI
import InputPrimitives

extension HoverPhase {
  public var location: CGPoint? {
    switch self {
      case .active(let loc): loc
      case .ended: nil
    }
  }

  public var interactionPhase: InteractionPhase {
    switch self {
      case .active: .changed
      case .ended: .ended
    }
  }
}
