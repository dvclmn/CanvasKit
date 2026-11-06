//
//  CanvasArtwork.swift
//  CanvasDemo
//
//  Created by Dave Coleman on 14/5/2026.
//

import SwiftUI

enum SampleContent {
  case image(SampleImage) 
  case vectorShapes
  case drawing // Like paperbark?
}

enum SampleImage {
  case sunflower
}

extension SampleImage {
  var image: Image { .init(imageRef) }

  private var imageRef: ImageResource {
    switch self {
      case .sunflower: .sunflower
    }
  }

  var attribution: String? {
    switch self {
      case .sunflower: """
        Photo by [Linus Belanger](https://unsplash.com/@linusbelanger?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/photos/a-single-sunflower-blooms-against-a-bright-blue-sky-ysB8453OSbI?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)
        """

    }
  }
}
