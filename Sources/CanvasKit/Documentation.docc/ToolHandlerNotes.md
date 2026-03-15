# ToolHandler notes

Example setup

```swift
// 1. Create a handler with your domain's tools and bindings:
var toolHandler = ToolHandler(
  baseTool: .select,
  tools: CanvasTool.defaultTools + [.text],
  bindings: ToolBinding.defaultBindings() + [
    .makeToolBinding(for: .text, key: "t")
  ]
)

// 2. Feed key events:
toolHandler.handleKeyDown("h")
toolHandler.handleKeyUp("h")

// 3. Read the effective tool:
let tool = toolHandler.effectiveTool

// 4. Get the tool list for your toolbar:
let tools = toolHandler.availableTools  // derived from registry + bindings

```
