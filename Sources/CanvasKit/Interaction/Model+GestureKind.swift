//
//  Model+GestureKind.swift
//  BaseComponents
//
//  Created by Dave Coleman on 10/8/2025.
//

import Foundation

/// # Touch Gestures
/// - Zoom
/// - Pan
/// - Rotation
///
/// # Drag Gestures
/// - Pan
/// - Select
/// - Resize
/// - Tap (considered zero-length drag)
///
/// Tool-based (should only be allowed when x tool is selected)
/// - Pan (Drag)
/// - Select
/// - Resize

public enum DragGestureKind {
  case pan
  case zoom
  case select
  case resize
  case none
  
  public var name: String {
    switch self {
      case .pan: "Pan"
      case .zoom: "Zoom"
      case .select: "Select"
      case .resize: "Resize"
      case .none: "None"
    }
  }
}

