//
//  Tools.swift
//  CanvasKit
//
//  Created by Dave Coleman on 9/5/2026.
//

/// Compatibility name for the tool catalogue value.
///
/// Prefer ``ToolConfiguration`` in new code; it makes the boundary clearer:
/// configuration describes the tools a canvas supports, while ``ToolHandler``
/// owns runtime selection and key-held overrides.
public typealias Tools = ToolConfiguration
