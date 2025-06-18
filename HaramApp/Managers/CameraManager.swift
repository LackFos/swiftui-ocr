//
//  CameraManager.swift
//  HaramApp
//
//  Created by Elvis on 17/06/25.
//

import SwiftUI
import AVFoundation

class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    let session = AVCaptureSession()
    let sessionOutput = AVCapturePhotoOutput()
    
    @Published var capturedImage: UIImage? = nil
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                guard let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                    print("No camera available")
                    return
                }
                
                let cameraInput = try AVCaptureDeviceInput(device: cameraDevice)
                
                if(self.session.canAddInput(cameraInput)) {
                    self.session.addInput(cameraInput)
                }
                
                if(self.session.canAddOutput(self.sessionOutput)) {
                    self.session.addOutput(self.sessionOutput)
                }

                self.session.startRunning()
            } catch {
                print("Error setting up camera: \(error)")
            }
        }
    }
    
    func capture() {
        let config = AVCapturePhotoSettings()
        sessionOutput.capturePhoto(with: config, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("Could not get image data")
            return
        }
        
        guard let image = UIImage(data: imageData) else {
            print("Successfully captured image!")
            return
        }
        
        capturedImage = image
    }
}
