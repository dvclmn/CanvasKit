//
//  CanvasInteraction.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 8/3/2026.
//

import BasePrimitives
import GestureKit
import SwiftUI

/// `CanvasInteraction`'s state is owned outside of CanvasKit,
/// by the project *using* CanvasKit. E.g. in the case of DrawString,
/// this is owned by `BaseContainer` view.
@Observable
public final class CanvasInteraction {
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

extension CanvasInteraction {
  public func resetAll() {

  }
}
