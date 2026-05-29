# AGENTS.md

CanvasKit (a swift package) exposes a SwiftUI container View providing functionality for Pan and Zoom using gestures and pointer events. It also has support for configurable Tools, such as Select, Pan and Zoom tools.

It is currently in beta, and is being developed closely alongside another package [ToolKit](~/Apps/_ Swift Packages/ToolKit/Sources).

This is Dave’s first open source library, and care is being taken to balance the convenience of his swift tooling, against the cost of package dependencies and the effect on consumers of CanvasKit. There is an ongoing effort to cull ToolKit, identify what is useful and what can be moved out elsewhere, and exactly what CanvasKit should / shouldn’t depend on.

Note: This directory is the CanvasKit repository root, however the [workspace](~/Apps/_%20Swift%20Packages/CanvasKit/CanvasKit.xcworkspace) up one level pulls in both CanvasKit and [ToolKit](~/Apps/_ Swift Packages/ToolKit/Sources) as local dependancies, so build/package resolution via this workspace rather than potentially-stale remote origin/cache is usually more effective.

## Challenges
* Public API surface
* Will write more soon

## Current in-progress goals
* Write in-progress goals