//
//  Model+TrackpadMapStrategy.swift
//  LilyPad
//
//  Created by Dave Coleman on 24/6/2025.
//

import SwiftUI

extension CGSize {
  public static let trackpadAspectRatio: CGFloat = 10.0 / 16.0
  public static var trackpadSize: CGSize {
    let width: CGFloat = 700
    let height: CGFloat = width * trackpadAspectRatio
    return CGSize(width: width, height: height)
  }
}
