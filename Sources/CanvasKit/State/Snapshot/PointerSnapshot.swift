//
//  PointerSnapshot.swift
//  CanvasKit
//
//  Created by Dave Coleman on 26/4/2026.
//

import GeometryPrimitives

/// Consumer-ready pointer values already mapped into `CanvasSpace`.
struct PointerSnapshot: Sendable {
  let tap: Point<CanvasSpace>?
  let drag: Rect<CanvasSpace>?
  let hover: Point<CanvasSpace>?
  let isInsideCanvas: Bool
}
