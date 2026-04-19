Tool context: don’t over-model it yet

Tool = default intent resolver. Not an exclusive mode.

Tools answer questions like:

“If a pointer drag begins right now, what intent should it resolve to?”
“What domains am I allowed to claim authority over?”

Modifier keys temporarily override that answer.

Avoids a rigid mode machine.

---

Current tool: Selection
Pointer down + drag → SelectionDrag

Hold spacebar
Pointer down + drag → PanViewport

---

Tool didn’t change

Intent resolution did

---

Public surface:

- `CanvasTool` defines a tool
- `CanvasToolKind` gives it a stable identity
- `ToolConfiguration` owns tools, bindings, and selected kind
- `onCanvasToolAction` surfaces tool-emitted domain events
