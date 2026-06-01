# Pointer Styles

CanvasKit tools can resolve a semantic pointer style for the current
interaction context.

```swift
struct ZoomTool: CanvasTool {
  let kind: CanvasToolKind = .zoom
  let name = "Zoom"
  let icon = "magnifyingglass"

  var dragConfiguration: PointerDragConfiguration {
    .init(behaviour: .continuous(axes: .vertical))
  }

  var inputCapabilities: [ToolCapability] {
    [
      ToolCapability(interaction: .drag, intent: .zoom),
      ToolCapability(interaction: .tap, intent: .zoom),
    ]
  }

  func resolvePointerStyle(
    context: InteractionContext
  ) -> CanvasPointerStyle {
    context.modifiers.contains(.option) ? .zoomOut : .zoomIn
  }

  func resolveInteraction(
    context: InteractionContext,
    currentTransform: TransformState
  ) -> ToolResolution {
    .passthrough
  }
}
```

## Version support

CanvasKit supports macOS 14 and later, but SwiftUI's native pointer-style API is
available to CanvasKit on macOS 15 and later.

On macOS 15 and later, ``CanvasView`` automatically maps ``CanvasPointerStyle``
to SwiftUI's native pointer styles.

On macOS 14, ``CanvasView`` still resolves the current ``CanvasPointerStyle``,
but CanvasKit does not change the system cursor itself. Apps that need custom
cursor behaviour on macOS 14 should observe the resolved style and bridge it
through their own AppKit cursor handling.

```swift
@State private var pointerStyle: CanvasPointerStyle?

var body: some View {
  CanvasView(
    size: documentSize,
    pointerStyle: $pointerStyle,
    toolConfiguration: toolConfiguration
  ) {
    ArtworkView()
  }
}
```

The binding receives `nil` when CanvasKit has no active interaction context, and
a ``CanvasPointerStyle`` once the current tool has resolved a style.

## Rationale

CanvasKit exposes ``CanvasTool`` as public API, so the return type of
``CanvasTool/resolvePointerStyle(context:)`` becomes part of every custom tool's
source contract.

Returning SwiftUI's native `PointerStyle` would make the protocol unavailable to
CanvasKit's macOS 14 support range. Returning ToolKit's compatibility type would
make CanvasKit's public API depend on ToolKit's `ViewTools` target and all of
that compatibility layer's associated types.

``CanvasPointerStyle`` is intentionally narrower. It names the pointer feedback
that CanvasKit's canvas tools currently need:

- `.default`
- `.grabIdle`
- `.grabActive`
- `.zoomIn`
- `.zoomOut`

That keeps CanvasKit responsible for canvas semantics, while platform-specific
cursor compatibility remains either internal to CanvasKit where native support
exists, or app-owned where older OS support requires AppKit-specific behaviour.
