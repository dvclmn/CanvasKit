//
//  CanvasInputResolver.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 2/4/2026.
//

import InteractionKit
import InteractionKit
import SwiftUI

/// Centralises input resolution for `CanvasInteractionState`.
struct CanvasInputResolver {
  let source: InteractionSource?
  let phase: InteractionPhase
  let modifiers: Modifiers
  let activeTool: (any CanvasTool)?
  let transform: TransformState

  var pointerStyle: PointerStyleCompatible? {
    activeTool?.resolvePointerStyle(context: interactionContext)
  }

  func resolve() -> CanvasInputResolution {
    .init(
      globalAdjustment: globalAdjustment,
      toolResolution: toolResolution,
    )
  }

  private var interactionContext: InteractionContext {
    .init(source: source, phase: phase, modifiers: modifiers)
  }

  private var toolResolution: ToolResolution {
    guard shouldResolveTool else { return .none }
    return activeTool?.resolvePointerInteraction(
      context: interactionContext,
      currentTransform: transform,
    ) ?? .none
  }

  private var shouldResolveTool: Bool {
    guard let source else { return false }
    let capabilities = activeTool?.inputCapabilities ?? []

    return switch source {
      case .pointerTapGesture: capabilities.contains(.pointerTap)
      case .pointerDragGesture: capabilities.contains(.pointerDrag)
      case .continuousHover: capabilities.contains(.pointerHover)
      case .swipeGesture: capabilities.contains(.swipe)
      case .pinchGesture: capabilities.contains(.pinch)
    }
  }

  private var globalAdjustment: CanvasAdjustment {
    guard let source else { return .none }

    return switch source {
      case .swipeGesture(let delta, _): globalSwipeAdjustment(delta: delta)
      case .pinchGesture(let scale): .updateScale(scale)
      case .continuousHover(let point): .updatePointerHover(point)
      case .pointerTapGesture, .pointerDragGesture:
        /// Pointer events are handled by the active tool
        .none
    }
  }

  private func globalSwipeAdjustment(delta: Size<ScreenSpace>) -> CanvasAdjustment {

    /// If Option is held during a Swipe, it is interpreted as Zoom, not Pan
    guard modifiers.contains(.option) else {
      let newTranslation = transform.translation + delta
      return .updateTranslation(newTranslation)
    }

    /// Each point contributes up to 0.5% zoom change at sensitivity = 1.0
    let factor = ZoomComputation.factorFromDelta(
      CGSize(width: 0, height: delta.cgSize.height),
      weights: .vertical,
    )
    return .zoomAdjustment(for: transform, by: factor)
  }
}
