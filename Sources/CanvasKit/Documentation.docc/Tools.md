Tool context: don’t over-model it yet

Tool = default intent resolver. Not an exclusive mode.

Tools answer questions like:

“If a pointer drag begins right now, what intent should it resolve to?”
“What domains am I allowed to claim authority over?”

Modifier keys temporarily override that answer.

Avoids a rigid mode machine.

---

Committed tool: Selection
Pointer down + drag → SelectionDrag

Hold spacebar
Pointer down + drag → PanViewport

---

Committed tool didn’t change

Effective tool / intent resolution did

---

Public surface:

- `CanvasTool` defines a tool
- `CanvasToolKind` gives it a stable identity
- `ToolConfiguration` owns tools, bindings, and committed/base kind
- `ToolHandler` resolves the effective runtime tool, including key-held overrides
- `onCanvasToolAction` surfaces tool-emitted domain events


---

ToolRegistry: “these are the tools this canvas/project supports”
ToolSelection: “this is the user’s current committed tool”
ToolHandler: “given keys/modifiers/temporary overrides, what is effective right now?”

Example of progressive disclosure for tools:

```swift
CanvasView(
  size: size,
  tools: .default
) {
  content
}
  
```

More custom:

```
CanvasView(
  size: size,
  tools: ToolRegistry(
    tools: [
      SelectTool(),
      PanTool(),
      ZoomTool(),
      BrushTool(),
    ]
  )
) {
  content
}

```

External state example:

```
@State private var toolSelection = ToolSelection(.select)

CanvasView(
  size: size,
  tools: projectTools,
  toolSelection: $toolSelection
) {
  content
}
  
```


