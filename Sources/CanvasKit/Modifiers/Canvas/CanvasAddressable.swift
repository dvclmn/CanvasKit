//
//  CanvasView+Extensions.swift
//  CanvasKit
//
//  Created by Dave Coleman on 6/4/2026.
//

import SwiftUI

/// ``CanvasView`` declares conformance to this.
///
/// Allows CanvasKit-only View modifiers to define View extensions
/// that will only show in autocomplete results when:
/// a) Defined directly on `CanvasView` itself
/// b) Defined after other existing CanvasKit modifiers
///
/// This way CanvasKit-specific modifiers do not pollute autocomplete
/// results for other SwiftUI views.
///
/// Example modifiers: `ZoomRangeModifier`, `ArtworkOutlineModifier`
public protocol CanvasAddressable {}

/// Preserve CanvasAddressable across modifiers,
/// rather than losing this context via opaque `some View`
extension ModifiedContent: CanvasAddressable where Content: CanvasAddressable {}
