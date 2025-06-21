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
    
    @Published var boundingBox: CGRect? = nil // Add this for live bounding boxes
    @Published var previewSize: CGSize = .zero // Add this to store preview dimensions
    
    
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
    
    func onScanningIngredient(sampleBuffer: CMSampleBuffer, connection: AVCaptureConnection) {
        let orientation = CGImagePropertyOrientation(connection.videoOrientation)

        let textRecognitionRequest = VNRecognizeTextRequest(completionHandler: scanIngredient)
        textRecognitionRequest.recognitionLanguages = ["ko-KR"]
        textRecognitionRequest.recognitionLevel = .accurate
        
        
        do {
            let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: orientation)
            try handler.perform([textRecognitionRequest])
        } catch {
            print("Failed to perform recognition")
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
            print("Failed to perform recognition")
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
        
        // Find the first observation that contains the desired text
        let foundObservation = observations.first { observation in
            guard let topCandidate = observation.topCandidates(1).first else { return false }
            return topCandidate.string.contains("원재료")
        }
        
        if let observation = foundObservation {
                var finalBox: CGRect? = nil

                do {
                    // 1. GET A PRECISE BOX: Find the range of the specific keyword.
                    if let topCandidate = observation.topCandidates(1).first,
                       let specificRange = topCandidate.string.range(of: "원재료") {
                        
                        // Ask Vision for the box of ONLY that specific range.
                        let boxObservation = try topCandidate.boundingBox(for: specificRange)
                        finalBox = boxObservation?.boundingBox
                    }
                } catch {
                    print("⚠️ Could not get specific bounding box, falling back. Error: \(error)")
                }
                
                // Fallback: If getting the precise box failed, use the one for the whole line.
                if finalBox == nil {
                    finalBox = observation.boundingBox
                }
                
                // 2. FIX TIMING: Dispatch the UI update to the main thread.
                //    This is critical for positional accuracy.
                DispatchQueue.main.async {
                    self.isIngredientDetected = true
                    self.boundingBox = finalBox
                }

            } else {
                // If the text is no longer found, clear the box on the main thread too.
                DispatchQueue.main.async {
                    self.isIngredientDetected = false
                    self.boundingBox = nil
                }
            }
    }
}

extension CGImagePropertyOrientation {
    init(_ orientation: AVCaptureVideoOrientation) {
        switch orientation {
        case .portrait: self = .right
        case .portraitUpsideDown: self = .left
        case .landscapeRight: self = .up
        case .landscapeLeft: self = .down
        @unknown default: self = .up
        }
    }
}
