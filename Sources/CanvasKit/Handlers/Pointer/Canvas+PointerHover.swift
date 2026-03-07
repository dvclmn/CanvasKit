//
//  Handler+PointerHoverMapping.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 28/2/2026.
//

import BasePrimitives
import SwiftUI

extension CanvasHandler {
  public var viewportContext: ViewportContext? {
    geometry?.viewportContext(
      zoom: zoomClamped,
      pan: transform.panState.pan
        //      pan: transform.panState.pan
    )
  }

  public var pointerHoverMapperNative: NativePointerHoverHandler? {
    guard let artworkFrameInViewport, let canvasSize = geometry?.canvasSize else {
      return nil
    }
    return NativePointerHoverHandler(
      artworkFrameInViewport: artworkFrameInViewport,
      canvasSize: canvasSize,
      zoom: zoomClamped
    )
  }

}

// MARK: - Legacy
extension CanvasHandler {

  //  public var pointerHoverMapperLegacy: PointerHoverHandler? {
  //    guard let viewportContext else { return nil }
  //    return PointerHoverHandler(context: viewportContext)
  //  }

  /// Pointer location in the named viewport coordinate space.
  public var pointerHoverViewport: CGPoint? {
    pointer.pointerHover.value
  }

  /// Legacy global/screen representation retained for compatibility.
  public var pointerHoverGlobal: CGPoint? {
    guard let point = pointerHoverViewport, let viewportRect = geometry?.viewportRect else {
      return nil
    }
    return CGPoint(
      x: viewportRect.minX + point.x,
      y: viewportRect.minY + point.y
    )
  }

  //  public var pointerHoverMappedLegacy: HoverMapping? {
  //    guard let pointerHoverGlobal, let mapper = pointerHoverMapperLegacy else { return nil }
  //    return mapper.map(screenPoint: pointerHoverGlobal)
  //  }

  public var pointerHoverMappedNative: HoverMapping? {

    guard let pointerHoverViewport else {
      printMissing("pointerHoverViewport", for: "pointerHoverMappedNative")
      return nil
    }

    guard let mapper = pointerHoverMapperNative else {
      printMissing("pointerHoverMapperNative", for: "pointerHoverMappedNative")
      return nil
    }

    return mapper.map(viewportPoint: pointerHoverViewport)
  }

  public var pointerHoverMapped: HoverMapping? {
    pointerHoverMappedNative
    //    pointerHoverMappedNative ?? pointerHoverMappedLegacy
  }

  public var pointerHoverScreenPoint: Point<ScreenSpace>? {
    guard let pointerHoverGlobal else { return nil }
    return Point<ScreenSpace>(fromPoint: pointerHoverGlobal)
  }

  public var pointerHoverCanvasPoint: Point<CanvasSpace>? {
    pointerHoverMapped?.canvasPoint
  }

  /// Aka canvas local space
  public var pointerHoverCanvas: CGPoint? {
    pointerHoverMapped?.canvas
  }

  /// Nil when the hover point is outside the canvas bounds.
  public var pointerHoverCanvasIfInside: CGPoint? {
    guard let mapped = pointerHoverMapped else {
      printMissing("pointerHoverMapped", for: "pointerHoverCanvasIfInside")
      return nil
    }

    guard mapped.isInsideCanvas else {
      printDidNotSatisfy("mapped.isInsideCanvas", expectation: "true", for: "pointerHoverCanvasIfInside")

      return nil
    }
    return mapped.canvas
  }

  public var isPointerHoverInsideCanvas: Bool {
    pointerHoverMapped?.isInsideCanvas ?? false
  }

  public func updateHover(_ phase: HoverPhase) {
    pointer.pointerHover.update(phase)
    //    pointerHover.update(phase)
  }

  public func canvasPoint(fromViewportPoint point: CGPoint) -> CGPoint? {
    guard let mapper = pointerHoverMapperNative else { return nil }
    return mapper.map(viewportPoint: point).canvas
    //    if let mapper = pointerHoverMapperNative {
    //      return mapper.map(viewportPoint: point).canvas
    //    }

    //    guard let viewportRect = geometry?.viewportRect, let mapper = pointerHoverMapperLegacy else {
    //      return nil
    //    }
    //
    //    let global = CGPoint(
    //      x: viewportRect.minX + point.x,
    //      y: viewportRect.minY + point.y
    //    )
    //    return mapper.map(screenPoint: global).canvas
  }

  //  #if DEBUG
  //  public var pointerHoverMappingComparison: PointerHoverMappingComparison? {
  //
  //    DebugString("Hover") {
  //      Labeled("Viewport", value: pointerHoverViewport)
  //      Labeled("Global", value: pointerHoverGlobal)
  //      Labeled("Mapper Legacy", value: pointerHoverMapperLegacy)
  //      Labeled("Mapper Native", value: pointerHoverMapperNative)
  //    }
  //
  //    guard
  //      let viewportPoint = pointerHoverViewport,
  //      let globalPoint = pointerHoverGlobal,
  //      let legacyMapper = pointerHoverMapperLegacy,
  //      let nativeMapper = pointerHoverMapperNative
  //    else {
  //      return nil
  //    }
  //
  //    let legacy = legacyMapper.map(screenPoint: globalPoint)
  //    let native = nativeMapper.map(viewportPoint: viewportPoint)
  //    let drift = hypot(
  //      native.canvas.x - legacy.canvas.x,
  //      native.canvas.y - legacy.canvas.y
  //    )
  //
  //    return PointerHoverMappingComparison(
  //      legacyCanvas: legacy.canvas,
  //      nativeCanvas: native.canvas,
  //      canvasDrift: drift,
  //      legacyRoundTripError: legacyMapper.roundTripError(screenPoint: globalPoint),
  //      nativeRoundTripError: nativeMapper.roundTripError(viewportPoint: viewportPoint)
  //    )
  //  }

  //  public var pointerHoverRoundTripError: CGFloat? {
  //    pointerHoverMappingComparison?.nativeRoundTripError
  //  }
  //  #endif
}

#if DEBUG
public struct PointerHoverMappingComparison: Equatable {
  public let legacyCanvas: CGPoint
  public let nativeCanvas: CGPoint
  public let canvasDrift: CGFloat
  public let legacyRoundTripError: CGFloat
  public let nativeRoundTripError: CGFloat
}
#endif
