//
//  PointerState.swift
//  CanvasKit
//
//  Created by Dave Coleman on 7/3/2026.
//

/// Pointer observations before coordinate-space mapping.
///
/// `CanvasHandler` stores this as `PointerState<ViewportSpace>`. Public callback
/// modifiers receive separately mapped values in ``CanvasSpace``.
struct PointerState<Space>: Sendable, Equatable {
  var tap: PointerTapSnapshot<Space>?
  var hover: Point<Space>?
  var latestDrag: PointerDragSnapshot<Space>?
}
