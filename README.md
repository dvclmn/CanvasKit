# CanvasKit


[![macOS][macos-badge]][macos-url] [![Platforms][platforms-badge]][platforms-url] [![Documentation][documentation-badge]][documentation-url] [![License][license-badge]][license-url] [![Commit activity][commits-badge]][commits-url]

A SwiftUI container View that 

that aims to provide a subset of features standard in graphics applications.


> [!NOTE]
> CanvasKit is in beta, so features and APIs may change as it evolves. Please keep this in mind when trying it out, and I encourage your feedback.
 

- Standard viewport navigation such pan and zoom (rotate is on it's way), via both trackpad gestures and pointer events. [Read more]()
- A list of included Tools (Select, Pan and Zoom), w/ optional Tool Palette UI
- Simple custom Tool API to declare your own Tools
- Event-driven modifiers similar to SwiftUI's `onTapGesture(count:perform:)` for responding to user input and mapping viewport coordinates to your local artwork space


This works with any SwiftUI View, whether an Image, Text, or your own custom views.


## Features

### Viewport Navigation

> [!NOTE] 
> Canvas rotation is not yet supported, but will be implemented soon in a coming release.

### Canvas Tools
CanvasKit comes with three tools out-of-the-box;



- Select: Configurable marquee selection, coordinate space mapping
- Pan: 



## Installation

```swift
// Package.swift
dependencies: [
  .package(url: "https://github.com/dvclmn/CanvasKit", .upToNextMinor(from: "0.1.0")),
]
```


## Usage


```swift

import SwiftUI

struct ContentView: View {
  var body: some View {
    CanvasView {
      ArtworkView()
    }
  }
}

```

## Limitations

- Zoom


You may also find the below libraries interesting:

- [Zoomable](https://github.com/ryohey/Zoomable)


## License
[BSD 3-Clause License](https://github.com/dvclmn/CanvasKit?tab=BSD-3-Clause-1-ov-file) 

[platforms-url]: https://swiftpackageindex.com/dvclmn/CanvasKit
[platforms-badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdvclmn%2FCanvasKit%2Fbadge%3Ftype%3Dplatforms

[documentation-url]: https://swiftpackageindex.com/dvclmn/CanvasKit/main/documentation
[documentation-badge]: https://img.shields.io/badge/Documentation-DocC-blue

[license-url]: https://github.com/dvclmn/CanvasKit/blob/HEAD/LICENSE.md
[license-badge]: https://img.shields.io/github/license/dvclmn/CanvasKit?label=License

[commits-badge]: https://img.shields.io/github/commit-activity/w/dvclmn/CanvasKit
[commits-url]: https://img.shields.io/github/commit-activity/w/dvclmn/CanvasKit

[macos-url]: https://img.shields.io/badge/macOS-14.0%2B-brown
[macos-badge]: https://img.shields.io/badge/macOS-14.0%2B-brown
