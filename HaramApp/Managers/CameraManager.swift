//
//  CameraManager.swift
//  HaramApp
//
//  Created by Elvis on 17/06/25.
//

import SwiftUI
import AVFoundation

class CameraManager: NSObject, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    let session = AVCaptureSession()
    let sessionOutput = AVCapturePhotoOutput()
    let videoDataOutput = AVCaptureVideoDataOutput()
    
    var onImageCaptured: (UIImage) -> Void =  { _ in }
    var onScanningIngredient: (CMSampleBuffer, AVCaptureConnection) -> Void =  { _, _ in }
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                self.session.sessionPreset = .photo

                // 1. Get camera device
                guard let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                    print("No camera available")
                    return
                }
                
                // 2. Create a input session from camera device
                let cameraInput = try AVCaptureDeviceInput(device: cameraDevice)
                
                // 3. Add input to the session
                if(self.session.canAddInput(cameraInput)) {
                    self.session.addInput(cameraInput)
                }
                
                // 4. Add photo output to the session
                if(self.session.canAddOutput(self.sessionOutput)) {
                    self.session.addOutput(self.sessionOutput)
                }
                
                // 5. Add video output to the session
                if self.session.canAddOutput(self.videoDataOutput) {
                    self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInitiated))
                    self.session.addOutput(self.videoDataOutput)
                }

                // 6. Start the camera
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
        print(image.size)
        onImageCaptured(image)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.onScanningIngredient(sampleBuffer, connection)
    }
}
