//
//  ShiftCodeDisplay.swift
//  Valet
//
//

import SwiftUI

struct ShiftCodeDisplay: View {
    let code: String
    var showShareButton: Bool = true
    var showQRCode: Bool = false
    @State private var isShareSheetPresented = false
    let customerName: String
    
    var body: some View {
        VStack(spacing: 10) {
            // Code display
            HStack {
                Text("SHIFT CODE:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                Text(code)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.bold)
                    .kerning(1.5)
                    .foregroundColor(.blue)
                    
                if showShareButton {
                    Button(action: {
                        isShareSheetPresented = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.systemGray6).opacity(0.6))
            .cornerRadius(8)
            
            // Optional QR Code
            if showQRCode {
                Image(uiImage: generateQRCode(from: code))
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(8)
            }
        }
        .sheet(isPresented: $isShareSheetPresented) {
            // Share Sheet for iOS to share the shift code
            ShareSheetView(shiftCode: code, customerName: customerName)
        }
    }
    
    // Generate QR code from string
    private func generateQRCode(from string: String) -> UIImage {
        let data = string.data(using: .ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                let context = CIContext()
                if let cgImage = context.createCGImage(output, from: output.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        
        // Fallback if QR code generation fails
        return UIImage(systemName: "qrcode") ?? UIImage()
    }
}

// Share Sheet for reuse
struct ShareSheetView: UIViewControllerRepresentable {
    let shiftCode: String
    let customerName: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let message = "Join my valet shift for \(customerName) using code: \(shiftCode)"
        let activityViewController = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
