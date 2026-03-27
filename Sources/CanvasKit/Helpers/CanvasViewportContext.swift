//
//  CanvasViewportContext.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 3/3/2026.
//

//import SwiftUI

//public protocol CanvasViewportContext: Sendable, Equatable {
//  /// The idea is that this should account for safe areas etc,
//  /// and can express this by virtue of being a rect (not just a size)
//  var viewportRect: Rect<ScreenSpace> { get }
//  
//  
//  var canvasSize: Size<CanvasSpace> { get }
//  var anchor: UnitPoint { get }
//}
//
//extension CanvasViewportContext {
//
//  public var canvasCGSize: CGSize { canvasSize.cgSize }

//  public func viewportMapping(from state: TransformState) -> CanvasViewportMapping? {
//    viewportMapping(
//      zoom: state.scale.value,
//      pan: state.translation.value.screenSize
//    )
//  }

//  public func viewportMapping(
//    zoom: CGFloat,
//    pan: Size<ScreenSpace>
//    //    pan: CGSize
//  ) -> CanvasViewportMapping? {
//    guard isValidForCoordinateMapping else { return nil }
//    return CanvasViewportMapping(
//      viewportRect: viewportRect,
//      pan: pan,
//      zoom: zoom,
//      canvasSize: canvasSize,
//      anchor: anchor
//    )
//  }

//  public var isValidForCoordinateMapping: Bool {
//    viewportRect.width > 0
//      && viewportRect.height > 0
//      && canvasSize.width > 0
//      && canvasSize.height > 0
//  }
//}
