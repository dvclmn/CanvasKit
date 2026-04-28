//
//  GestureIntent.swift
//  CanvasKit
//
//  Created by Dave Coleman on 28/4/2026.
//

/// Starting with finite/default intents at first
public enum GestureIntent : Sendable{
//public struct GestureIntent : Sendable{
  
  /// Important: Need to see Modifiers to properly resolve. E.g. a Swipe
  /// gesture resolves to Pan by default; with Option it becomes Zoom.
//  public enum Preset: Sendable {
    case pan
    case zoom
    case rotate
    
    case adjustBrushSize
//  }
}
