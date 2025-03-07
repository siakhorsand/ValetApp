//
//  DirectCameraView.swift
//  Valet
//
//

import SwiftUI
import AVFoundation
import UIKit

struct DirectCameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.showsCameraControls = true
        
        // Custom overlay view to match the app's theme
        let overlay = UIView()
        overlay.frame = picker.view.frame
        
        // Title label at the top
        let titleLabel = UILabel()
        titleLabel.text = "Take Car Photo"
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        titleLabel.frame = CGRect(x: 0, y: 0, width: overlay.frame.width, height: 50)
        overlay.addSubview(titleLabel)
        
        // Instructions at the bottom
        let instructionsLabel = UILabel()
        instructionsLabel.text = "Position the car clearly in the frame"
        instructionsLabel.textColor = UIColor.white
        instructionsLabel.font = UIFont.systemFont(ofSize: 14)
        instructionsLabel.textAlignment = .center
        instructionsLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        instructionsLabel.frame = CGRect(
            x: 0,
            y: overlay.frame.height - 100,
            width: overlay.frame.width,
            height: 40
        )
        overlay.addSubview(instructionsLabel)
        
        // Add corner guides for framing
        let cornerSize: CGFloat = 40
        let cornerThickness: CGFloat = 3
        let primaryColor = UIColor(ValetTheme.primary)
        
        // Top-left corner
        let topLeftHorizontal = UIView(frame: CGRect(x: 60, y: 120, width: cornerSize, height: cornerThickness))
        topLeftHorizontal.backgroundColor = primaryColor
        overlay.addSubview(topLeftHorizontal)
        
        let topLeftVertical = UIView(frame: CGRect(x: 60, y: 120, width: cornerThickness, height: cornerSize))
        topLeftVertical.backgroundColor = primaryColor
        overlay.addSubview(topLeftVertical)
        
        // Top-right corner
        let topRightHorizontal = UIView(frame: CGRect(x: overlay.frame.width - 60 - cornerSize, y: 120, width: cornerSize, height: cornerThickness))
        topRightHorizontal.backgroundColor = primaryColor
        overlay.addSubview(topRightHorizontal)
        
        let topRightVertical = UIView(frame: CGRect(x: overlay.frame.width - 60 - cornerThickness, y: 120, width: cornerThickness, height: cornerSize))
        topRightVertical.backgroundColor = primaryColor
        overlay.addSubview(topRightVertical)
        
        // Bottom-left corner
        let bottomLeftHorizontal = UIView(frame: CGRect(x: 60, y: overlay.frame.height - 160, width: cornerSize, height: cornerThickness))
        bottomLeftHorizontal.backgroundColor = primaryColor
        overlay.addSubview(bottomLeftHorizontal)
        
        let bottomLeftVertical = UIView(frame: CGRect(x: 60, y: overlay.frame.height - 160 - cornerSize, width: cornerThickness, height: cornerSize))
        bottomLeftVertical.backgroundColor = primaryColor
        overlay.addSubview(bottomLeftVertical)
        
        // Bottom-right corner
        let bottomRightHorizontal = UIView(frame: CGRect(x: overlay.frame.width - 60 - cornerSize, y: overlay.frame.height - 160, width: cornerSize, height: cornerThickness))
        bottomRightHorizontal.backgroundColor = primaryColor
        overlay.addSubview(bottomRightHorizontal)
        
        let bottomRightVertical = UIView(frame: CGRect(x: overlay.frame.width - 60 - cornerThickness, y: overlay.frame.height - 160 - cornerSize, width: cornerThickness, height: cornerSize))
        bottomRightVertical.backgroundColor = primaryColor
        overlay.addSubview(bottomRightVertical)
        
        // Add the overlay to the camera controller
        picker.cameraOverlayView = overlay
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: DirectCameraView
        
        init(_ parent: DirectCameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                
                // Provide haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}
