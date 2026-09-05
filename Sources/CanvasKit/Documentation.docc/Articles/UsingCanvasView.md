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

## Logical size and measured layout

An explicit `size` describes the logical document extent. SwiftUI can round the artwork's layout bounds to display pixels, so those bounds may differ slightly from the requested size; Apple describes this in [Building Custom Views with SwiftUI](https://developer.apple.com/videos/play/wwdc2019/237/). CanvasKit captures the unscaled layout size and the frame in ``ViewportSpace`` in one geometry observation. ``CoordinateSpaceMapper`` infers zoom from those matching measurements while retaining the original logical size for document bounds and input containment.

When an explicit size changes, CanvasKit waits for a matching geometry observation before publishing mapped input. It does not combine a new document size with the previous artwork's frame. The mapper uses measured geometry rather than the committed transform scale, so its scale and origin describe the same layout observation.

The mapper supports translation and uniform scale. It compares the inferred horizontal and vertical scales with a relative tolerance of 0.1%. If measured geometry enters a non-uniform state, CanvasKit reports the two scales and both sizes once, and uses the smaller valid scale. Pointer conversions do not log. Further warnings are suppressed until uniform geometry resumes. Rotation and non-uniform transforms remain unsupported; their axis-aligned frames can imply unequal scales and inaccurate input mapping.

### Fractional grid example

Big Blue Terminal at 28 points yields a measured character width of `56 / 3` points in DrawString's 48-column measurement sample. At a 2× display scale in a centred viewport, a 16-column artwork requests a width of `298⅔` points but can receive a layout width of `299`. This changes the container bounds without stretching its content.

Comparing the transformed width with the requested width would infer `zoom × 299 / 298⅔` horizontally and `zoom` vertically. The former absolute scale-difference threshold of `0.001` therefore began warning above `0.896` zoom, despite a uniform visual transform. The same isolated SwiftUI layout reproduction explains the reported artwork thresholds:

| Artwork | Columns | Requested width (pt) | Measured layout width (pt) | Former warning above zoom |
| --- | ---: | ---: | ---: | ---: |
| `justM` | 1 | 18⅔ | 19 | 0.056 (below the app's 0.1 minimum) |
| `threeByFour` | 3 | 56 | 56 | Never from this rounding |
| `chicken` | 16 | 298⅔ | 299 | 0.896 |
| `unicorn` | 37 | 690⅔ | 691 | 2.072 |
| `dwarfFortress` | 80 | 1493⅓ | 1493 | 4.480 |
| `complex` | 85 | 1586⅔ | 1587 | 4.760 |
| `measureWidth` | 99 | 1848 | 1848 | Never from this rounding |

These are reproduced layout measurements, not a capture of the running DrawString app; rounding can vary with display scale and placement. Using the measured local extent as the denominator removes this source of false scaling diagnostics and avoids small mapping errors when a dimension rounds down. Increasing the tolerance alone would leave that mapping error in place.
