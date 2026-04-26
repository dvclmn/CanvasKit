//
//  TransformSnapshot.swift
//  CanvasKit
//
//  Created by Dave Coleman on 25/4/2026.
//

import SwiftUI

struct TransformSnapshot {
  
  /// There is a zoom clamped property already in the Env,
  /// so this doesn't need to come in clamped.
  let zoom: Double
  let pan: CGSize
  let rotation: Angle

}
