//
//  CanvasClipping+Meta.swift
//  CanvasKit
//
//  Created by Dave Coleman on 6/8/2026.
//

// Helps with Picker controls
extension CanvasClipping {
  enum Meta {
    case clipped
    case dimmed
    case none
  }
}

extension CanvasClipping.Meta {
  var displayString: String {
    let parent: CanvasClipping = .init(fromMeta: self)
    return parent.displayString(showsDimmingValue: false)
  }
}

extension CanvasClipping {
  // Private so this can't be used elsewhere, as it doesn't
  // preserve Dimming level
  fileprivate init(fromMeta meta: CanvasClipping.Meta) {
    switch meta {
      case .clipped: self = .clipped
      case .dimmed: self = .dimmed(0)
      case .none: self = .none
    }
  }
}

extension CanvasClipping {
  
  var meta: Meta {
    get {
      switch self {
        case .clipped: .clipped
        case .dimmed(let cGFloat): .dimmed
        case .none: .none
      }
    }
    
    set {
      switch newValue {
          
      }
    }
  }
}
