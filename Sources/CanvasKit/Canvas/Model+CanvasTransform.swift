//
//  Model+Transform.swift
//  BaseComponents
//
//  Created by Dave Coleman on 5/7/2025.
//

// import BaseHelpers
import SwiftUI

public struct TransformTypes: OptionSet, Sendable {
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
  public let rawValue: Int
  
  public static let pan = Self(rawValue: 1 << 0)
  public static let zoom = Self(rawValue: 1 << 1)
  public static let rotation = Self(rawValue: 1 << 2)
  public static let all: Self = [.pan, .zoom, .rotation]
}


//public struct CanvasTransform: Equatable, Sendable {

//  public static let identity = CanvasTransform()

//  public init() {}
//}

// MARK: - Coord Space transforms
//extension CanvasHandler {

  /// Zoom to 100%
  //  public mutating func resetTransformations(_ transformations: TransformTypes = .all) {
  //    if transformations.contains(.zoom) {
  //      zoomHandler.resetZoom()
  //    }
  //    if transformations.contains(.pan) {
  //      pan = .zero
  //    }
  //    if transformations.contains(.rotation) {
  //      rotation = .zero
  //    }
  //  }

  

  

  /// Computes where the top-left corner of the target should
  /// be (after zooming) positioned within the original space,
  /// assuming the target is *centred* and offset by `pan`.
  //  var canvasTopLeadingCornerInViewport: CGPoint? {
  //
  //  }

//
//  public func mapToViewport(
//    canvasPoint point: CGPoint
//  ) -> CGPoint {
//    
//  }

  // MARK: - Zoom operations

//}



