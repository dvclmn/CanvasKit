# CanvasKit

[![Platforms][platforms-badge]][platforms-url] [![Documentation][documentation-badge]][documentation-url] [![License][license-badge]][license-url]

CanvasKit is a SwiftUI canvas container for panning, zooming, coordinate mapping, and tool-driven pointer interaction.

It wraps ordinary SwiftUI content (the "Canvas") in an interactive viewport. Your app owns the artwork, document, diagram, or custom view inside the canvas; CanvasKit supplies the surrounding behaviour: trackpad pan and pinch zoom, pointer tap/drag/hover capture, canvas-space coordinate mapping, and a small tool system for interpreting input.

> [!WARNING]
> CanvasKit is in beta. The core viewport behaviour is usable, but the public API, dependency surface, and tool ergonomics are still evolving. Pin versions or commits if you build against it today.

## Contents
- [Quick Start](#quick-start)
- [Current Status](#current-status)
- [Installation](#requirements-and-installation)
- [What CanvasKit Provides](#what-canvaskit-provides)
- [Usage](#common-usage)
- [Use Cases](#use-cases)
- [Documentation](#documentation)
- [See Also](#see-also)
- [License](#license)

## Quick Start

The smallest setup is just `CanvasView` around any SwiftUI view:

```swift
import CanvasKit
import SwiftUI

struct ContentView: View {
  var body: some View {
    CanvasView {
      ArtworkView()
    }
  }
}
```

With no parameters, CanvasKit measures the content and keeps pan and zoom state internally. Pass a fixed `size` when your content has a known document or artwork size:

```swift
CanvasView(size: CGSize(width: 800, height: 600)) {
  ArtworkView()
}
```

That is enough to get the default viewport interactions:
- Swipe pans the viewport.
- Option-swipe zooms the viewport.
- Pinch zooms the viewport.
- Pointer tap, drag, and hover can be routed through canvas tools.

See [Usage](#Usage) for more advanced examples.

## Current Status
CanvasKit is a work-in-progress. The below is an effort to outline the known gaps so you have a good sense of the current shape going in.

### Limitations
- Rotation not yet supported.
- Currently macOS only. No immediate plans for iOS support, but if there enough squeaky wheels, then maybe it’ll jump up the list
- Panning offset is not yet clamped in any way, so the canvas can be moved far away from the visible viewport.
- The public API surface, access control, and ergonomics are not final.
- The dependency story is still evolving, especially the relationship with [ToolKit](https://github.com/dvclmn/ToolKit).
- Test coverage is not broad enough yet for a stable release claim.

### Known Issues
- Coordinate-space mapping is one of the least mature moving parts. It works for the current event modifiers, but needs more stress-testing across layout changes, external transform ownership, and programmatic coordinate conversion.
- Canvas event modifiers such as `onCanvasDrag` currently rely on environment values injected by `CanvasView`. For now, attach them inside the `CanvasView` content hierarchy.
- `canvasClipping(_:)` uses SwiftUI container values and is only effective on macOS 15 and newer. On macOS 14 it currently behaves as a no-op.

### Roadmap
- Rotation support.
- Sensible pan clamping, re-centring, or bounds-aware behaviour.
- Drag and drop support using `Transferable`, for loading artwork, documents, or whatever semantic subject the canvas is wrapping.
- A richer Tools API, with more flexible out-of-the-box UI components.
- Stronger coordinate mapping tests and clearer APIs for mapping outside the canvas hierarchy.
- A smaller, more stable dependency and public API surface before a proper release.

## Installation
Add CanvasKit to your Xcode project or Swift package 

```
https://github.com/dvclmn/CanvasKit
```

```swift
// Package.swift
dependencies: [
  .package(
    url: "https://github.com/dvclmn/CanvasKit", 
    .upToNextMinor(from: "0.1.0")
  )
]
```

CanvasKit currently declares:
- macOS 14.0+
- Swift tools version 6.3
- SwiftUI

## What CanvasKit Provides

- A SwiftUI `CanvasView` container that can wrap any SwiftUI content.
- Viewport navigation with pan and zoom gestures.
- Optional external ownership of `TransformState` for document state, undo/redo, inspectors, or programmatic view controls.
- Canvas-space pointer events via `onCanvasTap`, `onCanvasDrag`, and `onCanvasHover`.
- A small tool system with built-in Select, Pan, and Zoom tools.
- Optional tool palette UI and keyboard bindings.
- Basic canvas presentation controls such as viewport background and canvas clipping.

## Common Usage
### Configure The Viewport
Canvas-specific modifiers are available directly on `CanvasView`:

```swift
CanvasView(size: documentSize) {
  ArtworkView()
}
.zoomRange(0.1...8)
.zoomSensitivity(0.45)
.canvasBackground(Color(white: 0.08))
```

Use a transform binding when the rest of your app needs to inspect or mutate the current viewport transform:

```swift
@State private var transform = TransformState()

CanvasView(
  size: documentSize,
  transform: $transform
) {
  ArtworkView()
}
```

That makes programmatic controls straightforward:

```swift
Button("Reset View") {
  transform.reset()
}
```

### Handle Canvas Events
Attach canvas event modifiers to descendants of `CanvasView` when you need pointer values mapped into `CanvasSpace`:

```swift
CanvasView(size: documentSize) {
  ArtworkView()
    .onCanvasTap { point in
      selection.selectItem(at: point)
    }
    .onCanvasDrag { event in
      selection.updateMarquee(event.rect, phase: event.phase)
    }
    .onCanvasHover { phase in
      hoverState = phase
    }
}
```

### Use Tools
CanvasKit includes Select, Pan, and Zoom tools. The default bindings are:
- `V` for Select.
- `H` for Pan.
- `Z` for Zoom.
- Hold Space to temporarily spring-load Pan.

Enable the built-in palette with `toolPalette()`:

```swift
CanvasView(
  size: documentSize,
  toolConfiguration: .default
) {
  ArtworkView()
}
.toolPalette(alignment: .topLeading)
```

Create custom tools by conforming to `CanvasTool`, declaring the interactions the tool claims, and registering it in a `ToolConfiguration`. See the DocC article on tools for a fuller example.

## Use Cases
CanvasKit is most obvious in graphics and design-adjacent apps, but the underlying behaviour is useful anywhere a SwiftUI view needs to become a navigable surface:

- Image, illustration, or vector editing views.
- Diagram, flow-chart, and node-graph editors.
- Whiteboards, mind maps, and spatial planning tools.
- Large document, map, floor-plan, or schematic viewers.
- Annotation interfaces for screenshots, PDFs, images, or generated output.
- Timeline, canvas, or workspace regions inside otherwise ordinary productivity apps.

## Documentation
DocC documentation is available on Swift Package Index:
[swiftpackageindex.com/dvclmn/CanvasKit/main/documentation](https://swiftpackageindex.com/dvclmn/CanvasKit/main/documentation)

Good starting points:
- `CanvasView`
- `TransformState`
- `ToolConfiguration`
- `CoordinateSpaceMapper`

If you’re having difficulty with anything, or still have questions, [open a discussion](../discussions) or [create an issue](../issues) and I’ll do my best to help out.

## See Also
These projects are not all direct alternatives, but they are useful comparison points if you are exploring pan, zoom, infinite canvas, or canvas-style SwiftUI interfaces:

- [ryohey/Zoomable](https://github.com/ryohey/Zoomable)
- [dmytro-anokhin/advanced-scrollview](https://github.com/dmytro-anokhin/advanced-scrollview)
- [dmytro-anokhin/ShapeEdit](https://github.com/dmytro-anokhin/ShapeEdit)
- [benjaminRoberts01375/SwiftUI-Infinite-Grid](https://github.com/benjaminRoberts01375/SwiftUI-Infinite-Grid)
- [1amageek/swift-flow](https://github.com/1amageek/swift-flow)
- [chrisrecalis/swiftui-infinite-canvas](https://github.com/chrisrecalis/swiftui-infinite-canvas)

## License
CanvasKit is available under the [BSD 3-Clause License][license-url].

[platforms-url]: https://swiftpackageindex.com/dvclmn/CanvasKit
[platforms-badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdvclmn%2FCanvasKit%2Fbadge%3Ftype%3Dplatforms

[documentation-url]: https://swiftpackageindex.com/dvclmn/CanvasKit/main/documentation
[documentation-badge]: https://img.shields.io/badge/Documentation-DocC-blue

[license-url]: https://github.com/dvclmn/CanvasKit/blob/HEAD/LICENSE.md
[license-badge]: https://img.shields.io/github/license/dvclmn/CanvasKit?label=License
