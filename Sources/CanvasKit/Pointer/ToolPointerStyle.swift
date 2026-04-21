//
//  ToolPointerStyle.swift
//  CanvasKit
//
//  Created by Dave Coleman on 21/4/2026.
//

//public enum ToolPointerStyle: Sendable {
//  /// Displays an arrow in macOS and a circle in iPadOS and visionOS.
//  case `default`
//
//  /// Appropriate for selecting or inserting text in a horizontal layout.
//  /// Sometimes referred to as the I-beam pointer.
//  case horizontalText
//
//  /// Style appropriate for selecting or inserting text in a
//  /// vertical layout.
//  case verticalText
//
//  /// Style for precise rectangular selection, such as selecting a portion
//  /// of an image or multiple lines of text. It displays a crosshair
//  case rectSelection
//
//  /// Indicates that dragging to reposition content within specific bounds,
//  /// such as panning a large image, is possible. Displays an open hand to
//  /// indicate that the content can be repositioned.
//  ///
//  /// Typically it’s used along with `grabActive` while a mouse or trackpad is
//  /// actively clicked to indicate that the content is currently being repositioned.
//  case grabIdle
//
//  /// The style for actively dragging to reposition content within specific bounds.
//  /// Displays a closed hand to indicate that the content is currently being repositioned
//  case grabActive
//
//  /// The pointer style appropriate for content opens a URL link to a
//  /// webpage, document, or other item when clicked. Displays a pointing hand.
//  case link
//
//  /// Indicates that the content can be zoomed in.
//  /// Displays a magnifying glass with a plus symbol.
//  case zoomIn
//  case zoomOut
//
//  /// The pointer style for resizing a column, or vertical division.
//  case columnResize
//
//  /// The pointer style for resizing a column, or vertical division.
//  case columnResizeDirections(HorizontalDirection.Set)
//
//  /// Style for resizing a row, or horizontal division, in either direction.
//  case rowResize
//
//  /// Style for resizing a row, or horizontal division, in either direction.
//  case rowResizeDirections(VerticalDirection.Set)
//
//  case frameResize(
//    position: FrameResizePosition,
//    directions: FrameResizeDirection = .all,
//  )
//  /// `image` not currently supported
//  //  case image(Image, hotSpot: UnitPoint)
//
//}
//
//// MARK: - Enums
//extension ToolPointerStyle {
//  public enum HorizontalDirection {
//    case leading
//    case trailing
//  }
//
//  public enum VerticalDirection {
//    case up
//    case down
//  }
//}
//
//// MARK: - Option Sets
//extension ToolPointerStyle.HorizontalDirection {
//  public struct Set: OptionSet, Sendable {
//    public init(rawValue: Int) {
//      self.rawValue = rawValue
//    }
//    public let rawValue: Int
//
//    public static let leading = Self(rawValue: 1 << 0)
//    public static let trailing = Self(rawValue: 1 << 1)
//    public static let all: Self = [.leading, .trailing]
//  }
//}
//
//extension ToolPointerStyle.VerticalDirection {
//  public struct Set: OptionSet, Sendable {
//    public init(rawValue: Int) {
//      self.rawValue = rawValue
//    }
//    public let rawValue: Int
//
//    public static let up = Self(rawValue: 1 << 0)
//    public static let down = Self(rawValue: 1 << 1)
//    public static let all: Self = [.up, .down]
//  }
//}
//
//extension ToolPointerStyle {
//  public enum FrameResizePosition: Int8, CaseIterable, Sendable {
//    case top
//    case leading
//    case bottom
//    case trailing
//    case topLeading
//    case topTrailing
//    case bottomLeading
//    case bottomTrailing
//  }
//
//  public enum FrameResizeDirection: Int8, CaseIterable, Sendable {
//
//    /// Indicates that the frame can be resized inwards to be smaller.
//    case inward
//
//    /// Indicates that the frame can be resized outwards to be larger.
//    case outward
//
//    case all
//  }
//}
