//
//  CanvasEventModifiers.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 20/3/2026.
//

import BasePrimitives
import SwiftUI

// MARK: - onCanvasTap

/// Observes pointer tap events and delivers them in canvas-space.
//struct OnCanvasTapModifier: ViewModifier {
//  @Environment(CanvasInteractionState.self) private var interactionState
//
//  let action: (Point<CanvasSpace>) -> Void
//
//  func body(content: Content) -> some View {
//    content
//      .onChange(of: interactionState.pointer.tap) { _, newTap in
//        guard let screenPoint = newTap,
//          let mapper = interactionState.coordinateSpaceMapper
//        else { return }
//
//        let canvasPoint = mapper.canvasPoint(from: screenPoint)
//        action(canvasPoint)
//      }
//  }
//}
//
///// Observes pointer tap events and delivers them in screen-space.
//struct OnCanvasTapScreenModifier: ViewModifier {
//  @Environment(CanvasInteractionState.self) private var interactionState
//
//  let action: (Point<ScreenSpace>) -> Void
//
//  func body(content: Content) -> some View {
//    content
//      .onChange(of: interactionState.pointer.tap) { _, newTap in
//        guard let screenPoint = newTap else { return }
//        action(screenPoint)
//      }
//  }
//}

// MARK: - onCanvasDrag

/// Observes pointer drag events and delivers the rect in canvas-space.
/// Fires every frame the drag is active.
struct OnCanvasDragModifier: ViewModifier {
  @Environment(CanvasInteractionState.self) private var interactionState

  let action: (Rect<CanvasSpace>) -> Void

  func body(content: Content) -> some View {
    content
      .onChange(of: interactionState.pointer.drag) { _, newDrag in
        guard let screenRect = newDrag,
          let mapper = interactionState.coordinateSpaceMapper
        else { return }

        let canvasRect = mapper.canvasRect(from: screenRect)
        action(canvasRect)
      }
  }
}

/// Observes pointer drag events and delivers the rect in screen-space.
struct OnCanvasDragScreenModifier: ViewModifier {
  @Environment(CanvasInteractionState.self) private var interactionState

  let action: (Rect<ScreenSpace>) -> Void

  func body(content: Content) -> some View {
    content
      .onChange(of: interactionState.pointer.drag) { _, newDrag in
        guard let screenRect = newDrag else { return }
        action(screenRect)
      }
  }
}

// MARK: - canvasEventHandler (progressive enhancement)

/// A unified handler that receives all canvas events.
///
/// For consumers who want a single callback entry point rather than
/// individual `.onCanvasTap` / `.onCanvasDrag` modifiers.
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

        let canvasPoint = mapper.canvasPoint(from: screenPoint)
        handler(.tap(canvasPoint))
      }
      .onChange(of: interactionState.pointer.drag) { _, newDrag in
        guard let screenRect = newDrag,
          let mapper = interactionState.coordinateSpaceMapper
        else { return }

        let canvasRect = mapper.canvasRect(from: screenRect)
        handler(.drag(canvasRect))
      }
  }
}

// MARK: - View extensions

extension View {

  /// React to pointer taps in canvas-space.
  ///
  /// ```swift
  /// CanvasView(...)
  ///   .onCanvasTap { point in
  ///     let gridPos = gridPosition(from: point)
  ///     selectGlyph(at: gridPos)
  ///   }
  /// ```
//  public func onCanvasTap(
//    perform action: @escaping (Point<CanvasSpace>) -> Void
//  ) -> some View {
//    self.modifier(OnCanvasTapModifier(action: action))
//  }
//
//  /// React to pointer taps in screen-space.
//  public func onCanvasTap(
//    in space: ScreenSpace.Type,
//    perform action: @escaping (Point<ScreenSpace>) -> Void
//  ) -> some View {
//    self.modifier(OnCanvasTapScreenModifier(action: action))
//  }

  /// React to pointer drags in canvas-space. Fires every frame.
  ///
  /// ```swift
  /// CanvasView(...)
  ///   .onCanvasDrag { rect in
  ///     previewSelection(in: rect)
  ///   }
  /// ```
  public func onCanvasDrag(
    perform action: @escaping (Rect<CanvasSpace>) -> Void
  ) -> some View {
    self.modifier(OnCanvasDragModifier(action: action))
  }

  /// React to pointer drags in screen-space. Fires every frame.
  public func onCanvasDrag(
    in space: ScreenSpace.Type,
    perform action: @escaping (Rect<ScreenSpace>) -> Void
  ) -> some View {
    self.modifier(OnCanvasDragScreenModifier(action: action))
  }

  /// Handle all canvas events through a single callback.
  /// Events are delivered in canvas-space.
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
  public func canvasEventHandler(
    _ handler: @escaping (CanvasEvent) -> Void
  ) -> some View {
    self.modifier(CanvasEventHandlerModifier(handler: handler))
  }
}
