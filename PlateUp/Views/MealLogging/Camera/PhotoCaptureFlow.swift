//
//  PhotoCaptureFlow.swift
//  PlateUp
//
//  Multi-photo capture flow with voice integration
//

import SwiftUI
import AVFoundation
import UIKit

struct PhotoCaptureFlow: View {
    let includesVoice: Bool
    @Environment(\.dismiss) var dismiss
    @StateObject private var cameraModel = CameraModel()
    @State private var currentStep: CaptureStep = .camera
    @State private var capturedPhotos: [UIImage] = []
    @State private var voiceRecording: Data?
    @State private var voiceTranscript: String = ""
    
    enum CaptureStep {
        case camera
        case voice
        case review
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.plateUpBackground.ignoresSafeArea()
                
                switch currentStep {
                case .camera:
                    PhotoCaptureView(
                        cameraModel: cameraModel,
                        capturedPhotos: $capturedPhotos,
                        onComplete: {
                            if includesVoice {
                                withAnimation {
                                    currentStep = .voice
                                }
                            } else {
                                withAnimation {
                                    currentStep = .review
                                }
                            }
                        }
                    )
                    
                case .voice:
                    VoiceContextView(
                        voiceRecording: $voiceRecording,
                        voiceTranscript: $voiceTranscript,
                        onComplete: {
                            withAnimation {
                                currentStep = .review
                            }
                        },
                        onSkip: {
                            withAnimation {
                                currentStep = .review
                            }
                        }
                    )
                    
                case .review:
                    PhotoReviewView(
                        photos: capturedPhotos,
                        voiceTranscript: voiceTranscript,
                        includesVoice: includesVoice,
                        onConfirm: {
                            // Start analysis
                            startMealAnalysis()
                        },
                        onRetake: {
                            withAnimation {
                                capturedPhotos = []
                                voiceTranscript = ""
                                currentStep = .camera
                            }
                        }
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.plateUpGreen)
                }
            }
        }
        .onAppear {
            cameraModel.checkPermissions()
        }
    }
    
    private func startMealAnalysis() {
        // Navigate to analysis screen
        // For now, just dismiss
        dismiss()
    }
}

// MARK: - Camera Model
@MainActor
class CameraModel: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var showPermissionAlert = false
    
    private let session = AVCaptureSession()
    private var videoOutput = AVCapturePhotoOutput()
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert = true
        @unknown default:
            break
        }
    }
    
    private func setupCamera() {
        // Camera setup code
        // This would include configuring the capture session
    }
}

// MARK: - Photo Capture View
struct PhotoCaptureView: View {
    @ObservedObject var cameraModel: CameraModel
    @Binding var capturedPhotos: [UIImage]
    let onComplete: () -> Void
    
    @State private var showingImagePicker = true
    @State private var inputImage: UIImage?
    
    var photoCountText: String {
        switch capturedPhotos.count {
        case 0:
            return "Take your first photo"
        case 1:
            return "Take another angle (optional)"
        case 2:
            return "One more angle (optional)"
        case 3:
            return "Last photo (optional)"
        default:
            return "Maximum photos reached"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Camera permission handling
            if !cameraModel.isAuthorized {
                CameraPermissionView()
            } else {
                // Photo count indicator
                VStack(spacing: 8) {
                    Text("Photo \(capturedPhotos.count + 1) of 4")
                        .font(PlateUpTypography.headline)
                        .foregroundColor(.plateUpPrimaryText)
                    
                    Text(photoCountText)
                        .font(PlateUpTypography.subheadline)
                        .foregroundColor(.plateUpSecondaryText)
                }
                .padding()
                
                // Camera preview placeholder
                ZStack {
                    Color.plateUpSecondaryBackground
                    
                    VStack(spacing: 20) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.plateUpTertiaryText)
                        
                        Text("Camera Preview")
                            .font(PlateUpTypography.subheadline)
                            .foregroundColor(.plateUpSecondaryText)
                        
                        // Temporary: Use image picker
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Text("Choose Photo")
                                .font(PlateUpTypography.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Color.plateUpGreen)
                                .cornerRadius(PlateUpComponentStyle.mediumRadius)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                
                // Bottom controls
                VStack(spacing: 16) {
                    // Photo thumbnails
                    if !capturedPhotos.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(capturedPhotos.enumerated()), id: \.offset) { index, photo in
                                    Image(uiImage: photo)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.plateUpBorder, lineWidth: 1)
                                        )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 70)
                    }
                    
                    // Action buttons
                    HStack(spacing: 20) {
                        if capturedPhotos.isEmpty {
                            // Only show capture button
                            Button(action: capturePhoto) {
                                ZStack {
                                    Circle()
                                        .stroke(Color.plateUpGreen, lineWidth: 4)
                                        .frame(width: 70, height: 70)
                                    
                                    Circle()
                                        .fill(Color.plateUpGreen)
                                        .frame(width: 60, height: 60)
                                }
                            }
                        } else {
                            // Show continue and capture more
                            Button(action: onComplete) {
                                Text("Continue")
                                    .font(PlateUpTypography.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 120, height: 50)
                                    .background(Color.plateUpGreen)
                                    .cornerRadius(PlateUpComponentStyle.mediumRadius)
                            }
                            
                            if capturedPhotos.count < 4 {
                                Button(action: capturePhoto) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.plateUpGreen)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
                .padding()
                .background(Color.plateUpCardBackground)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
        .onChange(of: inputImage) { _ in
            if let inputImage = inputImage {
                capturedPhotos.append(inputImage)
                if capturedPhotos.count >= 4 {
                    onComplete()
                }
            }
        }
    }
    
    private func capturePhoto() {
        // In real implementation, this would capture from camera
        // For now, show image picker
        showingImagePicker = true
    }
}

// MARK: - Camera Permission View
struct CameraPermissionView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundColor(.plateUpTertiaryText)
            
            Text("Camera Access Required")
                .font(PlateUpTypography.headline)
                .foregroundColor(.plateUpPrimaryText)
            
            Text("Please enable camera access in Settings to scan your meals")
                .font(PlateUpTypography.subheadline)
                .foregroundColor(.plateUpSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: openSettings) {
                Text("Open Settings")
                    .font(PlateUpTypography.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.plateUpGreen)
                    .cornerRadius(PlateUpComponentStyle.mediumRadius)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.plateUpBackground)
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary // For testing; would be .camera in production
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}