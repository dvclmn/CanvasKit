//
//  InteractionActivity.swift
//  CanvasKit
//
//  Created by Dave Coleman on 28/8/2026.
//

public struct CanvasInteractionActivity: Sendable, Equatable {
  public let activeKinds: Set<Interaction.Kind>
  
  public static let none = Self(activeKinds: [])
  
  public var isActive: Bool {
    !activeKinds.isEmpty
  }
  
  public func contains(_ kind: Interaction.Kind) -> Bool {
    activeKinds.contains(kind)
  }
  
  public var isSwipeActive: Bool {
    contains(.swipe)
  }
  
  public var isDragActive: Bool {
    contains(.drag)
  }
}
