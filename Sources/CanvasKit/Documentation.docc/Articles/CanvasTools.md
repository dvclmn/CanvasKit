# Canvas Tools

Tools describe how CanvasKit should interpret selected interactions. They are
not an exclusive mode machine: global viewport gestures still have default
behaviour, while pointer input is routed through the effective tool when that
tool declares a matching ``ToolCapability``.

CanvasKit includes three tools:

- ``SelectTool`` records taps and draws marquee rectangles.
- ``PanTool`` pans the viewport with pointer drag.
- ``ZoomTool`` zooms with pointer tap or vertical drag.

## Configuration

``ToolConfiguration`` is the durable value that describes the available tools,
keyboard bindings, and spring-load timing.

```swift
let configuration = ToolConfiguration.default

CanvasView(
  size: documentSize,
  toolConfiguration: configuration
) {
  ArtworkView()
}
.toolPalette()
```

By default, `V`, `H`, and `Z` are sticky shortcuts for Select, Pan, and Zoom.
Space is a hold shortcut that temporarily spring-loads Pan while the key is
held.

## Custom tools

Create a tool by conforming to ``CanvasTool`` and declaring the interactions it
claims.

```swift
extension CanvasToolID {
  static let brush = Self("brush")
}

struct BrushTool: CanvasTool {
  let id: CanvasToolID = .brush
  let name = "Brush"
  let icon = "paintbrush"

  var dragConfiguration: PointerDragConfiguration { .continuous }

  var inputCapabilities: [ToolCapability] {
    [ToolCapability(interaction: .drag, intent: .custom)]
  }

  func resolvePointerStyle(
    context: InteractionContext
  ) -> CanvasPointerStyle {
    .default
  }

  func resolveInteraction(
    context: InteractionContext,
    currentTransform: TransformState
  ) -> ToolResolution {
    .passthrough
  }
}
```

Register custom tools by building a configuration. Reusing a built-in
``CanvasToolID`` replaces that tool while keeping shortcuts and selection
identity stable.

```swift
let configuration = ToolConfiguration(
  tools: [
    SelectTool(),
    PanTool(),
    ZoomTool(),
    BrushTool(),
  ],
  bindings: ToolBinding.defaultBindings() + [
    ToolBinding(
      KeyboardShortcut("b", modifiers: []),
      target: .brush,
      mode: .sticky
    ),
  ]
)
```

Return `.handled(...)` when the tool has resolved the interaction. Return
`.passthrough` when CanvasKit should continue to its default behaviour.

## Pointer style

Tools return ``CanvasPointerStyle`` rather than SwiftUI's native `PointerStyle`.
That keeps the public tool API available to CanvasKit's supported platform
range while still allowing CanvasKit to apply native pointer styles where the
operating system supports them.

On macOS 15 and later, ``CanvasView`` maps the resolved ``CanvasPointerStyle``
to SwiftUI's native pointer style support. On macOS 14, SwiftUI does not expose
that API, so CanvasKit leaves cursor mutation to the app. Pass a `pointerStyle`
binding to ``CanvasView`` if the app needs to bridge the semantic style into its
own AppKit compatibility layer.
