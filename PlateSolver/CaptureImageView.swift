//
//  CaptureImageView.swift
//  PlateSolver
//
//  Created by Brad Slayter on 6/28/22.
//

import SwiftUI

struct CaptureImageView {
    /// MARK: - Properties
    @Binding var isShown: Bool
    @Binding var image: Image?
    @Binding var apiService: APIService
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isShown: $isShown, image: $image, apiService: $apiService)
    }
}

extension CaptureImageView: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<CaptureImageView>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<CaptureImageView>) {
        
    }
}
