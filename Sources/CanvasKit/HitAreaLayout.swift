//
//  HitAreaLayout.swift
//  InteractionKit
//
//  Created by Dave Coleman on 29/3/2026.
//

import SwiftUI
import CanvasCore

//public struct HitAreaLayout {
//  let controlPoint: UnitPoint
//  let thickness: CGFloat
//  let offset: RectBoundaryPlacement
//  let shouldIncludeCorners: Bool
//
//  public init(
//    controlPoint: UnitPoint,
//    thickness: CGFloat,
//    offset: RectBoundaryPlacement,
//    shouldIncludeCorners: Bool,
//  ) {
//    self.controlPoint = controlPoint
//    self.thickness = thickness
//    self.offset = offset
//    self.shouldIncludeCorners = shouldIncludeCorners
//  }
//}
//
//extension HitAreaLayout {
//
//  public var alignment: Alignment {
//    controlPoint.toAlignment
//  }
//
//  /// Important: Remember this is for individual Hit Areas.
//  /// This does not represent the overall size or frame of the
//  /// Resizable View.
//  public var fillSizeMax: CGSize {
//    switch controlPoint.pointType {
//      case .horizontalEdge: CGSize(width: .infinity, height: thickness)
//      case .verticalEdge: CGSize(width: thickness, height: .infinity)
//      case .corner: shouldIncludeCorners ? CGSize(fromLength: thickness) : .zero
//      case .centre: .zero
//
//    }
//  }
//
//  /// Padding created to accomodate corners if present
//  public var edgePadding: EdgeInsets {
//    let inset = thickness
//    let padding: EdgeInsets =
//      switch (offset, shouldIncludeCorners) {
//        case (.outside, _): .zero
//        case (_, false): .zero
//        case (.inside, true): controlPoint.hitAreaPadding(inset)
//        case (.centre, true): controlPoint.hitAreaPadding(inset / 2)
//      }
//
//    return padding
//  }
//
//  public var rectOffset: CGSize {
//
//    let offsetAmount: CGFloat =
//      switch offset {
//        case .inside: .zero
//        case .outside: -thickness
//        case .centre: -thickness / 2
//      }
//    return controlPoint.offset(by: offsetAmount)
//  }
//
//}
//
//extension UnitPoint {
//  func hitAreaPadding(_ amount: CGFloat) -> EdgeInsets {
//    switch self {
//      case .top, .bottom:
//        /// Horizontal padding for horizontal edges
//        return EdgeInsets(top: 0, leading: amount, bottom: 0, trailing: amount)
//
//      case .leading, .trailing:
//        /// Vertical padding for vertical edges
//        return EdgeInsets(top: amount, leading: 0, bottom: amount, trailing: 0)
//
//      default:
//        /// Corners and center do not add padding here; handled by edgePadding logic
//        return .zero
//    }
//  }
//}
