//
//  Canvas+Rotation.swift
//  BaseComponents
//
//  Created by Dave Coleman on 28/7/2025.
//

import SwiftUI

public struct RotationHandler {
  
  public var rotation: Angle = .zero
  
  public init() {}
}
extension RotationHandler {
  public mutating func reset() {
    rotation = .zero
  }
}
