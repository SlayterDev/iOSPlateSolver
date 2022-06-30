//
//  CaptureButton.swift
//  PlateSolver
//
//  Created by Brad Slayter on 6/28/22.
//

import SwiftUI

struct CaptureButton: View {
    @Binding var image: Image?
    @Binding var showCaptureImageView: Bool
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            image?.resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 250, height: 250)
            .shadow(radius: 10)
            
            Button(action: {
                self.showCaptureImageView.toggle()
            }) {
                Image(systemName: "camera.fill")
                    .frame(width: 45, height: 45)
                    .background(.blue)
                    .tint(.white)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
        }
    }
}

struct CaptureButton_Previews: PreviewProvider {
    static var previews: some View {
        CaptureButton(image: .constant(Image(systemName: "photo")),
                      showCaptureImageView: .constant(false))
    }
}
