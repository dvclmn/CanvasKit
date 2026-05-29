//
//  CanvasView+Extensions.swift
//  CanvasKit
//
//  Created by Dave Coleman on 6/4/2026.
//

import SwiftUI

/// Marker protocol for views that can receive CanvasKit-specific modifiers.
///
/// ``CanvasView`` conforms to this so modifiers such as
/// `zoomRange(_:)` are offered only on canvas-related chains.
public protocol CanvasAddressable {}

/// Preserves ``CanvasAddressable`` across modifier chains.
extension ModifiedContent: CanvasAddressable where Content: CanvasAddressable {}
