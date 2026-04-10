//
//  InteractionAdjustment.swift
//  InteractionKit
//
//  Created by Dave Coleman on 8/4/2026.
//

/// Was first `CanvasAdjustment`, then `Interaction`,
/// now `InteractionAdjustment`
public enum InteractionAdjustment: Sendable {
  case transform(TransformAdjustment)
  case pointer(PointerAdjustment)
}
