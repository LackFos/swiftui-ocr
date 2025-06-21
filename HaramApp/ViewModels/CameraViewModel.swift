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
        
        // OCR Logic
        guard let cgImage = image.cgImage else {
            print("Something wrong")
            return
        }
        
        let textRecognitionRequest = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
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
        
        let recognizedStrings = observations.compactMap { observation in
            return observation.topCandidates(1).first?.string
        }
        
        let boundingRects: [CGRect] = observations.compactMap { observation in
            guard let candidate = observation.topCandidates(1).first else { return .zero }
            
            // Find the bounding-box observation for the string range.
            let stringRange = candidate.string.startIndex..<candidate.string.endIndex
            let boxObservation = try? candidate.boundingBox(for: stringRange)
            
            // Get the normalized CGRect value.
            let boundingBox = boxObservation?.boundingBox ?? .zero
            
            // Convert the rectangle from normalized coordinates to image coordinates.
            return VNImageRectForNormalizedRect(boundingBox,
                                                Int(self.capturedImage!.size.width),
                                                Int(self.capturedImage!.size.height))
        }
        
        print(boundingRects)
        print(recognizedStrings)
    }
}
