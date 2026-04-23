//
//  UnitPoint+Helpers.swift
//  CanvasKit
//
//  Created by Dave Coleman on 21/4/2026.
//

import SwiftUI

extension UnitPoint {
  package var toAlignment: Alignment {
    switch self {
      case .top: .top
      case .bottom: .bottom
      case .leading: .leading
      case .trailing: .trailing
      case .topLeading: .topLeading
      case .topTrailing: .topTrailing
      case .bottomLeading: .bottomLeading
      case .bottomTrailing: .bottomTrailing
      default: .center
    }
  }
}
