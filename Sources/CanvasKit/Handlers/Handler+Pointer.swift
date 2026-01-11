//
//  Handler+Pointer.swift
//  CanvasKit
//
//  Created by Dave Coleman on 11/1/2026.
//

import GestureKit

/// These are not neccesarily defined by the number of fingers
///
/// PointerInteraction
/// - operates in content space
/// - usually single primary pointer
/// - absolute positions matter
///
/// GestureInteraction
/// - operates in view / world / mode space
/// - often multi-pointer
/// - relative motion matters
///

struct PointerHandler {
  let phase: PointerPhase? = nil
}

extension PointerHandler {
  mutating func update(
    for kind: PointerInteractionKind,
    phase: PointerPhase?
  ) {
    
  }
}

public enum PointerInteractionKind {
  case tap
  case drag
  case hover
}
