//
//  ActivationMode.swift
//  CanvasKit
//
//  Created by Dave Coleman on 6/4/2026.
//


public enum ActivationMode: Sendable, Hashable {
  /// Spring-load while key is held (with debounce delay)
  case hold
  
  /// Press to switch tool; remains active until changed
  case sticky
  
  /// Press to toggle on/off
  case toggle
}
