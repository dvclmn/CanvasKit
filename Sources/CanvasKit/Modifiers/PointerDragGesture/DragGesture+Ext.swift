//
//  DragGesture.swift
//  CanvasKit
//
//  Created by Dave Coleman on 1/8/2025.
//

import SwiftUI

extension DragGesture.Value {

  public enum EndLocationKind {
    case standard
    case predicted
  }
  /// Creates a rect from an explicit start point to the chosen drag end point.
  ///
  /// Use `.predicted` to end the rect at `predictedEndLocation`.
  public func toRect(
    from start: CGPoint,
    end locationKind: EndLocationKind,
  ) -> CGRect {
    CGRect.boundingRect(
      from: start,
      to: locationKind == .predicted ? predictedEndLocation : location
    )
  }
}
