//
//  InteractionAdjustment.swift
//  InteractionKit
//
//  Created by Dave Coleman on 8/4/2026.
//

import InteractionKit

/// Was first `CanvasAdjustment`, then `Interaction`,
/// now `InteractionAdjustment`
public enum InteractionAdjustment: Sendable {
  case transform(TransformAdjustment)
  case pointer(PointerAdjustment)
  case none
}

extension InteractionAdjustment {
  func isSupported(by interaction: InteractionKinds.Element) -> Bool {
    switch self {
      case .transform(let transformAdjustment):
        transformAdjustment.supportedInteractions.contains(interaction)

      case .pointer(let pointerAdjustment):
        /// Pointer adjustments have no support limitations
        true

      case .none: true
    }
  }
}
