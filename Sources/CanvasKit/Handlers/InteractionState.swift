//
//  InteractionState.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/3/2026.
//

import BasePrimitives
import SwiftUI

@Observable
@dynamicMemberLookup
public final class InteractionState {
  public var pointer: PointerState
  public var transform: TransformState

  public init(
    pointer: PointerState = .initial,
    transform: TransformState = .initial
  ) {
    self.pointer = pointer
    self.transform = transform
  }
}

extension InteractionState {
  public subscript(dynamicMember: keyPath: ) {
    
  }
  public var isDragActive: Bool { pointer.drag.isActive }
}
