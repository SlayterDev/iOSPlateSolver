//
//  PhotoButton.swift
//  PlateSolver
//
//  Created by Brad Slayter on 6/28/22.
//

import SwiftUI

struct PhotoButton: View {
    @Binding var showCaptureImageView: Bool
    
    var body: some View {
        Button(action: {
            self.showCaptureImageView.toggle()
        }) {
            HStack {
                Image(systemName: "camera.fill")
                Text("Take Photo")
                    .fontWeight(.semibold)
            }
            .frame(width: 150, height: 50)
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(10.0)
                
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PhotoButton_Previews: PreviewProvider {
    static var previews: some View {
        PhotoButton(showCaptureImageView: .constant(false))
    }
}
