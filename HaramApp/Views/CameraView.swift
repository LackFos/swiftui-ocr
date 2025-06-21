import SwiftUI
import PhotosUI

struct CameraView: View {
    @ObservedObject var viewModel = CameraViewModel()
    @State var selectedItems: [PhotosPickerItem] = []
    @State private var previewLayer: AVCaptureVideoPreviewLayer?

    var body: some View {
        VStack {
            if(viewModel.capturedImage != nil) {
                Image(uiImage: viewModel.capturedImage!)
                    .resizable()
                    .scaledToFit()
            } else {
                CameraViewGuide(isIngredientDetected: viewModel.isIngredientDetected)
                
                ZStack {
                    CameraViewPreview(session: viewModel.cameraSession, previewLayer: $previewLayer)
                    GeometryReader { geometry in
                        if let normalizedBox = viewModel.boundingBox, let layer = self.previewLayer {
                            
                            // CORRECT: The View converts the normalized box to UI points
                            let pointRect = layer.layerRectConverted(fromMetadataOutputRect: normalizedBox)
                            let _ = print("pointRect: \(pointRect)")
                            // Now, draw the rectangle using the correctly converted pointRect
                            Rectangle()
                                .stroke(Color.green, lineWidth: 3)
                                .frame(
                                    width: pointRect.width,
                                    height: pointRect.height
                                )
                                .position(
                                    x: pointRect.midX,
                                    y: pointRect.midY
                                )
                        }
                    }
                    
                } .onChange(of: viewModel.boundingBox) { oldValue, newValue in
                    // This code block will run EVERY time 'viewModel.boundingBox' changes.
                    print("BoundingBox changed!")
                    print("  Old value: \(oldValue ?? .zero)")
                    print("  New value: \(newValue ?? .zero)")
                }
                
                
                CameraViewAction(onCapture: viewModel.captureImage)
            }
        }
    }
}
