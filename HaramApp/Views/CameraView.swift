import SwiftUI
import PhotosUI

struct CameraView: View {
    @ObservedObject var viewModel = CameraViewModel()
    @State var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        VStack {
            if(viewModel.capturedImage != nil) {
                Image(uiImage: viewModel.capturedImage!)
                    .resizable()
                    .scaledToFit()
            } else {
                CameraViewGuide(isIngredientDetected: viewModel.isIngredientDetected)
                CameraViewPreview(session: viewModel.cameraSession)
                CameraViewAction(onCapture: viewModel.captureImage)
            }
        }
    }
}
