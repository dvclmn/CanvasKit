//
//  CanvasEventModifiers.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 20/3/2026.
//

//import BasePrimitives
//import SwiftUI

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
//struct CanvasEventHandlerModifier: ViewModifier {
//  @Environment(CanvasInteractionState.self) private var interactionState
//
//  let handler: (CanvasEvent) -> Void
//
//  func body(content: Content) -> some View {
//    content
//      .onChange(of: interactionState.pointer.tap) { _, newTap in
//        guard let screenPoint = newTap,
//          let mapper = interactionState.coordinateSpaceMapper
//        else { return }
//        handler(.tap(CanvasSpace.convert(screenPoint, using: mapper)))
//      }
//      .onChange(of: interactionState.pointer.drag) { _, newDrag in
//        guard let screenRect = newDrag,
//          let mapper = interactionState.coordinateSpaceMapper
//        else { return }
//        handler(.drag(CanvasSpace.convert(screenRect, using: mapper)))
//      }
//  }
//}
