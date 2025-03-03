//
//  QRCodeScannerView.swift
//  Valet
//
//  Created by Claude on 3/3/2025.
//

import SwiftUI
import AVFoundation
import UIKit

struct QRCodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    @Binding var isShowing: Bool
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRCodeScannerView
        var viewController: UIViewController?
        var torchIsOn = false
        
        init(parent: QRCodeScannerView) {
            self.parent = parent
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                
                // Only process 6-character alphanumeric codes that look like shift codes
                let filteredValue = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                if filteredValue.count == 6 && filteredValue.range(of: "^[A-Z0-9]{6}$", options: .regularExpression) != nil {
                    // Provide haptic feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    // Flash the guide to indicate success
                    if let guideView = readableObject.bounds.nonzeroBounds {
                        flashSuccessOverlay(around: guideView)
                    }
                    
                    // Update the scanned code value after a small delay to show the success animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.parent.scannedCode = filteredValue
                        self.parent.isShowing = false
                    }
                }
            }
        }
        
        // Flash a success overlay
        private func flashSuccessOverlay(around bounds: CGRect) {
            guard let previewLayer = viewController?.view.layer.sublayers?.first as? AVCaptureVideoPreviewLayer,
                  let view = viewController?.view else { return }
            
            let transformedBounds = previewLayer.layerRectConverted(fromMetadataOutputRect: bounds)
            
            let successOverlay = UIView(frame: transformedBounds.insetBy(dx: -20, dy: -20))
            successOverlay.backgroundColor = UIColor.green.withAlphaComponent(0.3)
            successOverlay.layer.borderColor = UIColor.green.cgColor
            successOverlay.layer.borderWidth = 4
            successOverlay.layer.cornerRadius = 10
            view.addSubview(successOverlay)
            
            // Animate the success overlay
            UIView.animate(withDuration: 0.5, animations: {
                successOverlay.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                successOverlay.alpha = 0
            }, completion: { _ in
                successOverlay.removeFromSuperview()
            })
        }
        
        // Dismiss scanner
        @objc func dismissScanner() {
            DispatchQueue.main.async {
                self.parent.isShowing = false
            }
        }
        
        // Toggle torch - this needs to be in the Coordinator class to use with @objc
        @objc func toggleTorch(_ sender: UIButton) {
            guard let device = AVCaptureDevice.default(for: .video) else { return }
            
            if device.hasTorch {
                do {
                    try device.lockForConfiguration()
                    
                    if !torchIsOn {
                        try device.setTorchModeOn(level: 1.0)
                        torchIsOn = true
                        sender.setImage(UIImage(systemName: "flashlight.on.fill"), for: .normal)
                    } else {
                        device.torchMode = .off
                        torchIsOn = false
                        sender.setImage(UIImage(systemName: "flashlight.off.fill"), for: .normal)
                    }
                    
                    device.unlockForConfiguration()
                } catch {
                    print("Torch could not be used: \(error)")
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        context.coordinator.viewController = viewController
        
        let captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return viewController }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return viewController
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return viewController
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .code128, .code39, .code93, .ean8, .ean13, .pdf417]
        } else {
            return viewController
        }
        
        // Setup the preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        // Create a close button
        let closeButton = UIButton(frame: CGRect(x: 20, y: 50, width: 40, height: 40))
        closeButton.backgroundColor = UIColor(ValetTheme.surfaceVariant)
        closeButton.layer.cornerRadius = 20
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = UIColor.white
        closeButton.addTarget(context.coordinator, action: #selector(Coordinator.dismissScanner), for: .touchUpInside)
        viewController.view.addSubview(closeButton)
        
        // Add title at the top
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 10, width: viewController.view.bounds.width, height: 30))
        titleLabel.text = "Scan Shift Code"
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        viewController.view.addSubview(titleLabel)
        
        // Create a scan guide overlay
        let guideSize = CGSize(width: 250, height: 250)
        let guideView = UIView(frame: CGRect(
            x: (viewController.view.bounds.width - guideSize.width) / 2,
            y: (viewController.view.bounds.height - guideSize.height) / 2,
            width: guideSize.width,
            height: guideSize.height
        ))
        guideView.layer.borderColor = UIColor.white.cgColor
        guideView.layer.borderWidth = 2
        guideView.layer.cornerRadius = 12
        
        // Add corner guides
        let cornerSize: CGFloat = 40
        let cornerThickness: CGFloat = 3
        let primaryColor = UIColor(ValetTheme.primary)
        
        // Top-left corner
        let topLeftHorizontal = UIView(frame: CGRect(x: 0, y: 0, width: cornerSize, height: cornerThickness))
        topLeftHorizontal.backgroundColor = primaryColor
        guideView.addSubview(topLeftHorizontal)
        
        let topLeftVertical = UIView(frame: CGRect(x: 0, y: 0, width: cornerThickness, height: cornerSize))
        topLeftVertical.backgroundColor = primaryColor
        guideView.addSubview(topLeftVertical)
        
        // Top-right corner
        let topRightHorizontal = UIView(frame: CGRect(x: guideSize.width - cornerSize, y: 0, width: cornerSize, height: cornerThickness))
        topRightHorizontal.backgroundColor = primaryColor
        guideView.addSubview(topRightHorizontal)
        
        let topRightVertical = UIView(frame: CGRect(x: guideSize.width - cornerThickness, y: 0, width: cornerThickness, height: cornerSize))
        topRightVertical.backgroundColor = primaryColor
        guideView.addSubview(topRightVertical)
        
        // Bottom-left corner
        let bottomLeftHorizontal = UIView(frame: CGRect(x: 0, y: guideSize.height - cornerThickness, width: cornerSize, height: cornerThickness))
        bottomLeftHorizontal.backgroundColor = primaryColor
        guideView.addSubview(bottomLeftHorizontal)
        
        let bottomLeftVertical = UIView(frame: CGRect(x: 0, y: guideSize.height - cornerSize, width: cornerThickness, height: cornerSize))
        bottomLeftVertical.backgroundColor = primaryColor
        guideView.addSubview(bottomLeftVertical)
        
        // Bottom-right corner
        let bottomRightHorizontal = UIView(frame: CGRect(x: guideSize.width - cornerSize, y: guideSize.height - cornerThickness, width: cornerSize, height: cornerThickness))
        bottomRightHorizontal.backgroundColor = primaryColor
        guideView.addSubview(bottomRightHorizontal)
        
        let bottomRightVertical = UIView(frame: CGRect(x: guideSize.width - cornerThickness, y: guideSize.height - cornerSize, width: cornerThickness, height: cornerSize))
        bottomRightVertical.backgroundColor = primaryColor
        guideView.addSubview(bottomRightVertical)
        
        // Scan line animation
        let scanLine = UIView(frame: CGRect(x: 0, y: 0, width: guideSize.width, height: 2))
        scanLine.backgroundColor = primaryColor
        guideView.addSubview(scanLine)
        
        // Add the guide to the view controller
        viewController.view.addSubview(guideView)
        
        // Animate the scan line
        UIView.animate(withDuration: 1.5, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            scanLine.frame = CGRect(x: 0, y: guideSize.height - 2, width: guideSize.width, height: 2)
        }, completion: nil)
        
        // Add a label with instructions
        let instructionLabel = UILabel(frame: CGRect(x: 0, y: guideView.frame.maxY + 30, width: viewController.view.bounds.width, height: 40))
        instructionLabel.text = "Position QR code in the square"
        instructionLabel.textColor = UIColor.white
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        viewController.view.addSubview(instructionLabel)
        
        // Add a torch button - using the coordinator's toggleTorch method
        let torchButton = UIButton(frame: CGRect(x: viewController.view.bounds.width - 60, y: 50, width: 40, height: 40))
        torchButton.backgroundColor = UIColor(ValetTheme.surfaceVariant)
        torchButton.layer.cornerRadius = 20
        torchButton.setImage(UIImage(systemName: "flashlight.off.fill"), for: .normal)
        torchButton.tintColor = UIColor.white
        torchButton.tag = 0 // 0 = off, 1 = on
        torchButton.addTarget(context.coordinator, action: #selector(Coordinator.toggleTorch(_:)), for: .touchUpInside)
        viewController.view.addSubview(torchButton)
        
        // Set a rectangular scanning area
        metadataOutput.rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: guideView.frame)
        
        // Start the capture session on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the session if needed
    }
    
    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: Coordinator) {
        // Stop the capture session when view is dismissed
        if let previewLayer = uiViewController.view.layer.sublayers?.first as? AVCaptureVideoPreviewLayer,
           let session = previewLayer.session {
            session.stopRunning()
        }
        
        // Turn off torch if it's on
        if coordinator.torchIsOn {
            guard let device = AVCaptureDevice.default(for: .video), device.hasTorch, device.torchMode == .on else { return }
            
            do {
                try device.lockForConfiguration()
                device.torchMode = .off
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be turned off: \(error)")
            }
        }
    }
}

// Extension to handle CGRect in macOS/iOS
extension CGRect {
    var nonzeroBounds: CGRect? {
        if width > 0 && height > 0 {
            return self
        }
        return nil
    }
}
