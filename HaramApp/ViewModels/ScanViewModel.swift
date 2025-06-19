//
//  ScanViewModel.swift
//  HaramApp
//
//  Created by Elvis on 17/06/25.
//

import SwiftUI
import AVFoundation

class ScanViewModel: ObservableObject {
    let cameraManager: CameraManager
    @Published var capturedImage: UIImage?
    
    init() {
        self.cameraManager = CameraManager()
        self.cameraManager.onImageCaptured = self.onImageCaptured
    }

    var cameraSession: AVCaptureSession {
        return cameraManager.session
    }
    
    func captureImage() {
        cameraManager.capture()
    }

    func onImageCaptured(image: UIImage) -> Void {
        self.capturedImage = image
    }
}
