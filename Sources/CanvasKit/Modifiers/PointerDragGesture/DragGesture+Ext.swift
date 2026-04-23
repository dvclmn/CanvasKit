//
//  DragGesture.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 1/8/2025.
//

import SwiftUI

extension DragGesture.Value {

  public enum EndLocationKind {
    case standard
    case predicted
  }
  /// Will return `predictedEndLocation` for the end location,
  /// if `usingPredicated` is true. Otherwise will return `location`
  ///
  /// Note: Using explicit parameter for `start`, in case this comes from
  /// a stored start location, rather than the 'live' one from the Gesture.
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

extension CGRect {
  
  /// NOTE: Duplicated from BasePrimitives
  /// 
  /// Creates a rectangle from two points, ensuring positive width and height
  /// Useful for drag operations like marquee selection where the drag direction is unknown
  ///
  /// Note: previous methods `reversible`, `fromPoints(_:_:)`,
  /// `between(point1:point2:)`
  public static func boundingRect(
    from start: CGPoint, to end: CGPoint,
  ) -> CGRect {
    let size = CGSize(
      width: end.x - start.x,
      height: end.y - start.y,
    )
    return CGRect(origin: start, size: size).standardized
  }
}
