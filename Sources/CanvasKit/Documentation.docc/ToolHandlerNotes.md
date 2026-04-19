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

// 3. Ask the config for toolbar data:
let tools = toolConfiguration.availableTools
let shortcut = toolConfiguration.shortcut(for: .zoom)

// 4. Replace a built-in tool by reusing its kind:
//    MyZoomTool.kind = .zoom
toolConfiguration.register(MyZoomTool())
toolConfiguration.select(.zoom)
```
