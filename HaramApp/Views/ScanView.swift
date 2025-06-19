import SwiftUI
import PhotosUI
import AVFoundation

struct ScanView: View {
    @ObservedObject var viewModel = ScanViewModel()
    @State var selectedItems: [PhotosPickerItem] = []

    private func handleCaptureClick() {
        viewModel.captureImage()
    }

    var body: some View {
        VStack {
            if(viewModel.capturedImage != nil) {
                Image(uiImage: viewModel.capturedImage!)
                    .resizable()
                    .scaledToFit()
            } else {
                VStack {
                    HStack {
                        Text("Point camera to ingredients")
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .foregroundColor(.black)
                    .background(Color.white)
                    .cornerRadius(40)
                }
                .padding(.vertical, 24)
                .frame(height: 80)

                CameraPreviewView(session: viewModel.cameraSession)
                    .frame(height: 400)
                    .cornerRadius(40)

                HStack {
                    PhotosPicker(selection: $selectedItems, matching: .images) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                    .frame(width: 40, height: 40)
                    
                    Spacer()
                    
                    Button(action: handleCaptureClick) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                    }
                    
                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                    }
                }.padding(.all, 24)

                Spacer()
            }
        }
    }
}

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    var session: AVCaptureSession? {
        get { previewLayer.session }
        set { previewLayer.session = newValue }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}
}
