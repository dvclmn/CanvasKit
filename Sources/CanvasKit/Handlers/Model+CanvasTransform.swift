//
//  Model+Transform.swift
//  BaseComponents
//
//  Created by Dave Coleman on 5/7/2025.
//


import SwiftUI
import GestureKit

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


extension GestureKind.Meta {
  public init(from transformTypes: TransformTypes) {
    
//    self = switch transformTypes {
//      case .zoom: .zoom
//      case .pan: .zoom
//      case .rotation: .zoom
//      case .all: .zoom
//    }
    if transformTypes.contains(.zoom) {
      self = .zoom
////      zoomHandler.reset()
    }
    if transformTypes.contains(.pan) {
      self = .pan
////      panHandler.reset()
    }
    if transformTypes.contains(.rotation) {
      self = .rotate
////      rotationHandler.reset()
    } else {
      self = .none
    }
  }
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



