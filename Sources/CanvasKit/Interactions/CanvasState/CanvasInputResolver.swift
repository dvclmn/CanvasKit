//
//  CanvasInputResolver.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 2/4/2026.
//

import BasePrimitives
import InteractionKit
import SwiftUI

/// Centralises input resolution for `CanvasHandler`.
struct CanvasInputResolver {
  let context: InteractionContext
  //  let interaction: Interaction
  //  let source: InteractionSource
  //  let phase: InteractionPhase
  //  let modifiers: Modifiers
  let activeTool: (any CanvasTool)?
  let transform: TransformState

  var pointerStyle: PointerStyleCompatible? {
    activeTool?.resolvePointerStyle(context: context)
  }

  func resolve() -> CanvasInputResolution {
    .init(
      globalAdjustment: globalAdjustment,
      toolResolution: toolResolution,
    )
  }

  //  private var interactionContext: InteractionContext {
  //    .init(source: source, phase: phase, modifiers: modifiers)
  //  }

  /// Current tool may not declare any resolution
  private var toolResolution: ToolResolution? {
    guard shouldResolveTool else { return nil }
    return activeTool?.resolvePointerInteraction(
      context: context,
      currentTransform: transform,
    ) ?? .none
  }

  private var shouldResolveTool: Bool {
    let capabilities = activeTool?.inputCapabilities ?? []

    return switch context.interaction {
      case .swipe: capabilities.contains(.swipe)
      case .pinch: capabilities.contains(.pinch)
      case .rotation: capabilities.contains(.rotation)
      case .tap: capabilities.contains(.tap)
      case .drag: capabilities.contains(.drag)
      case .hover: capabilities.contains(.hover)
    }
  }

  private var globalAdjustment: TransformAdjustment {
    let interaction = context.interaction

    switch interaction {
      case .swipe(let delta): globalSwipeAdjustment(delta: delta)
      case .pinch(let scale): .scale(<#T##Double#>)
      case .rotation(let angle): .updateRotation(context.rotation)
    //      case .tap: .none
    //      case .drag: .none
    //      case .hover: .none
    }
  }
  //  private var globalAdjustment: CanvasAdjustment {
  //    switch source {
  //      case .swipeGesture(let delta, _): globalSwipeAdjustment(delta: delta)
  //      case .pinchGesture(let scale): .updateScale(scale)
  //      case .continuousHover(let point): .updatePointerHover(point)
  //      case .pointerTapGesture, .pointerDragGesture:
  //        /// Pointer events are handled by the active tool
  //        .none
  //    }
  //  }

  private func swipeAdjustment(delta: Size<ScreenSpace>) -> TransformAdjustment {

    /// If Option is held during a Swipe, it is interpreted as Zoom, not Pan
    guard context.modifiers.contains(.option) else {
      let newTranslation = transform.translation + delta
      return .translation(newTranslation)
    }

    /// Each point contributes up to 0.5% zoom change at sensitivity = 1.0
    let factor = ZoomComputation.factorFromDelta(
      CGSize(width: 0, height: delta.cgSize.height),
      weights: .vertical,
    )
    return .zoomAdjustment(for: transform, by: factor)
    //    return .zoomAdjustment(for: transform, by: factor)
  }
}
