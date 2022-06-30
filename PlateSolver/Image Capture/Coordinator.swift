//
//  Coordinator.swift
//  PlateSolver
//
//  Created by Brad Slayter on 6/27/22.
//

import SwiftUI

extension UIImagePickerController {
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.userInterfaceIdiom == .phone ? .portrait : .all
    }
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @Binding var isCoordinatorShown: Bool
    @Binding var imageInCoordinator: Image?
    @Binding var apiService: APIService
    
    init(isShown: Binding<Bool>, image: Binding<Image?>, apiService: Binding<APIService>) {
        _isCoordinatorShown = isShown
        _imageInCoordinator = image
        _apiService = apiService
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let unwrapImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        if let imgData = unwrapImage.jpegData(compressionQuality: 0.5) {
            apiService.uploadImage(imgData)
        }
        imageInCoordinator = Image(uiImage: unwrapImage)
        isCoordinatorShown = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isCoordinatorShown = false
    }
}
