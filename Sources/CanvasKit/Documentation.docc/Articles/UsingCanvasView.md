# Using CanvasView

``CanvasView`` is the main entry point. It accepts ordinary SwiftUI content and adds the viewport layer around it.

```swift
CanvasView {
  ArtworkView()
}
```

Pass `size` when the artwork has a known document size. If `size` is omitted, CanvasKit measures the content and uses that as the canvas size.

```swift
CanvasView(size: CGSize(width: 800, height: 600)) {
  ArtworkView()
}
```

Canvas-specific modifiers are available directly on ``CanvasView`` and remain available after other CanvasKit modifiers:

```swift
CanvasView(size: documentSize) {
  ArtworkView()
}
.zoomRange(0.1...8)
.zoomSensitivity(0.45)
.toolPalette(alignment: .topLeading)
```

Use `canvasBackground(_:)` to change the viewport background, and `canvasClipping(_:)` on child views to control how individual artwork layers render outside the canvas bounds.

```swift
CanvasView(size: documentSize) {
  Image("Artwork")
    .resizable()
    .canvasClipping(.dimmed(0.6))
}
.canvasBackground(Color(white: 0.08))
```

For pointer output, attach event modifiers to descendants that need to respond to mapped canvas-space values:

```swift
CanvasView(size: documentSize) {
  ArtworkView()
    .onCanvasTap { point in
      selection.selectItem(at: point)
    }
    .onCanvasHover { phase in
      hoverState = phase
    }
    .onCanvasDrag { event in
      selection.updateMarquee(
        from: event.start,
        through: event.current,
        phase: event.phase
      )
    }
}
```

`onCanvasTap`, `onCanvasDrag`, and `onCanvasHover` report values in ``CanvasSpace`` after CanvasKit has resolved the current transform and artwork frame. Hover observation is global; anchored drag publication remains tool-driven.
