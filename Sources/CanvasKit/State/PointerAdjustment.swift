//
//  PointerAdjustment.swift
//  CanvasKit
//
//  Created by Dave Coleman on 8/4/2026.
//

//import InteractionKit
import BasePrimitives

/// Also previously held by `CanvasAdjustment`
///
/// I think I'm struggling keeping this types strainght partially
/// because this holds things
///
/// that directly and only relate to a single-finger trackpad tap
/// or other pointer device like a mouse.
///
/// Whereas `TransformAdjustment` doesn't describe
/// a device at all, just the *transformation* from a device.
/// Be it a pointer device, or via multi-touch trackpad gesture.
public enum PointerAdjustment: Sendable {
  case tap(Point<ScreenSpace>)
  case hover(Point<ScreenSpace>)
  case drag(Rect<ScreenSpace>)
}
