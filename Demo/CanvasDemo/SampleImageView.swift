//
//  SampleImageView.swift
//  CanvasDemo
//
//  Created by Dave Coleman on 6/11/2026.
//

import SwiftUI

struct SampleImageView: View {
  let sampleImage: SampleImage
  var body: some View {

    sampleImage.image
      .resizable()
      .scaledToFill()
//      .canvasClipping(clipping)

  }
}
