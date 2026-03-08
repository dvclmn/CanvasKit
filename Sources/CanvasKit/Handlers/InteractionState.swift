//
//  InteractionState.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/3/2026.
//

import SwiftUI
import BasePrimitives

@Observable
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
