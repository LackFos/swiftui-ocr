//
//  ScanViewModel.swift
//  HaramApp
//
//  Created by Elvis on 17/06/25.
//

import SwiftUI
import AVFoundation
import Vision

class CameraViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var isIngredientDetected: Bool = false
    
    let cameraManager: CameraManager

    init() {
        self.cameraManager = CameraManager()
        self.cameraManager.onImageCaptured = self.onImageCaptured
        self.cameraManager.onScanningIngredient = self.onScanningIngredient
    }
    
    var cameraSession: AVCaptureSession {
        return cameraManager.session
    }
    
    func captureImage() {
        cameraManager.capture()
    }
    
    func onScanningIngredient(sampleBuffer: CMSampleBuffer) {
        let textRecognitionRequest = VNRecognizeTextRequest(completionHandler: scanIngredient)
        textRecognitionRequest.recognitionLanguages = ["ko-KR"]
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.minimumTextHeight = 0.3

        let visionRequestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer)

        do {
            try visionRequestHandler.perform([textRecognitionRequest])
        } catch {
            print("OK")
        }
    }
    
    func onImageCaptured(image: UIImage) -> Void {
        self.capturedImage = image
        
        // OCR Logic
        guard let cgImage = image.cgImage else {
            print("Something wrong")
            return
        }
        
        let textRecognitionRequest = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        textRecognitionRequest.recognitionLanguages = ["ko-KR"]
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.minimumTextHeight = 0.3

        let visionRequestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        do {
            try visionRequestHandler.perform([textRecognitionRequest])
        } catch {
            print("OK")
        }
    }
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            return
        }
        
        let words = observations.compactMap { observation in
            return observation.topCandidates(1).first?.string
        }
    }
    
    func scanIngredient(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            return
        }
        
        let words = observations.compactMap { observation in
            return observation.topCandidates(1).first?.string
        }
        
        for word in words {
            if(word.contains("원재료")) {
                self.isIngredientDetected = true
                return
            }
        }
        
        self.isIngredientDetected = false
    }
}
