# ``CanvasKit``

## Data flow

### External State

Comes from *outside* CanvasHandler, e.g. the Environment.
Uses the below example to sync the handler with the Env.

```swift
.task(id: externalData) { 
  store.updateExternalData(externalData) 
}
```

| State              | Source                         |
|--------------------|--------------------------------|
| `viewportRect`     | Environment. Usually comes from as high up the View hierarchy as possible, e.g. App `@main` or `ContentView` |
| `canvasSize`       | `CanvasView` initialiser       |
| `modifierKeys`     | Environment.                   | 


### Internal State
Is owned by the Handler (or a Canvas View), and added to the Environment for other domains to consume.
Uses the below example, to sync the Handler with the Environment.
```swift
.environment(\.panOffset, store.pan)
```



| State              | Flow                           |
|--------------------|--------------------------------|
| Pan                | Two-finger/drag Gesture → CanvasHandler → Environment   |
| Zoom       | `CanvasView` initialiser       |
| `modifierKeys`     | Environment.                   | 
