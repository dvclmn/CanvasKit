# ToolHandler notes

Example setup

```swift
// 1. Create a value-type configuration in app state:
@State private var toolConfiguration = ToolConfiguration()

// 2. Hand it to CanvasView:
CanvasView(
  size: canvasSize,
  transform: $transform,
  toolConfiguration: $toolConfiguration
) {
  Canvas(...)
}

// 3. Ask the config for durable toolbar data:
let tools = toolConfiguration.tools
let shortcut = toolConfiguration.shortcut(for: .zoom)

// 4. Replace a built-in tool by reusing its kind:
//    MyZoomTool.kind = .zoom
toolConfiguration.register(MyZoomTool())
toolConfiguration.commitTool(.zoom)
```

Terminology:

- `ToolConfiguration.committedToolKind` is the persistent/base selection.
- `ToolHandler.effectiveToolKind` is the tool being used right now, including
  temporary overrides such as Space-held Pan.
- `.hold` bindings arm immediately; `.sticky` bindings commit on quick release
  and become spring-loads only after `springLoadDelay`.
