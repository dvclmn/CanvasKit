//
//  CanvasEventModifiers.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 20/3/2026.
//

import BasePrimitives
import SwiftUI

public struct CanvasDragEvent<Space> {
  let rect: Rect<Space>
  let phase: InteractionPhase
}

/// Observes pointer drag events and delivers the rect in the requested coordinate space.
struct OnCanvasDragModifier<Space: CanvasCoordinateSpace>: ViewModifier {
  @Environment(CanvasInteractionState.self) private var interactionState

  let action: (CanvasDragEvent<Space>) -> Void
//  let action: (Rect<Space>) -> Void

  func body(content: Content) -> some View {
    content
      .onChange(of: interactionState.pointer.drag) { _, newDrag in
        
        action(.init(rect: Space.convert(<#T##screenRect: Rect<ScreenSpace>##Rect<ScreenSpace>#>, using: <#T##CoordinateSpaceMapper#>), phase: <#T##InteractionPhase#>))
//        action(Space.convert(screenRect, using: mapper))
      }
  }
}

extension OnCanvasDragModifier {
  private func handleAction(_ newDrag: Rect<ScreenSpace>?) {
    guard
      let screenRect = newDrag,
      let mapper = interactionState.coordinateSpaceMapper
    else { return }
    
    let rect = Space.convert(screenRect, using: <#T##CoordinateSpaceMapper#>)
    let event = CanvasDragEvent(rect: <#T##Rect<Space>#>, phase: <#T##InteractionPhase#>)
  }
}

// MARK: - canvasEventHandler

/// A unified handler that receives all canvas events in canvas-space.
///
/// ```swift
/// CanvasView(...)
///   .canvasEventHandler { event in
///     switch event {
///     case .tap(let point):
///       selectGlyph(at: gridPosition(from: point))
///     case .drag(let rect):
///       previewSelection(in: rect)
///     }
///   }
/// ```
struct CanvasEventHandlerModifier: ViewModifier {
  @Environment(CanvasInteractionState.self) private var interactionState

  let handler: (CanvasEvent) -> Void

  func body(content: Content) -> some View {
    content
      .onChange(of: interactionState.pointer.tap) { _, newTap in
        guard let screenPoint = newTap,
          let mapper = interactionState.coordinateSpaceMapper
        else { return }
        handler(.tap(CanvasSpace.convert(screenPoint, using: mapper)))
      }
      .onChange(of: interactionState.pointer.drag) { _, newDrag in
        guard let screenRect = newDrag,
          let mapper = interactionState.coordinateSpaceMapper
        else { return }
        handler(.drag(CanvasSpace.convert(screenRect, using: mapper)))
      }
  }
}

// MARK: - View extensions

extension View {

  /// React to pointer drags in the given coordinate space (defaults to canvas-space).
  /// Fires every frame the drag is active.
  ///
  /// ```swift
  /// CanvasView(...)
  ///   .onCanvasDrag { rect in
  ///     previewSelection(in: rect)
  ///   }
  ///
  /// CanvasView(...)
  ///   .onCanvasDrag(in: ScreenSpace.self) { rect in
  ///     drawOverlay(at: rect)
  ///   }
  /// ```
  public func onCanvasDrag<Space: CanvasCoordinateSpace>(
    in space: Space.Type = CanvasSpace.self,
    perform action: @escaping (Rect<Space>) -> Void
  ) -> some View {
    self.modifier(OnCanvasDragModifier<Space>(action: action))
  }

  /// Handle all canvas events through a single callback.
  /// Events are delivered in canvas-space.
  public func canvasEventHandler(
    _ handler: @escaping (CanvasEvent) -> Void
  ) -> some View {
    self.modifier(CanvasEventHandlerModifier(handler: handler))
  }
}
