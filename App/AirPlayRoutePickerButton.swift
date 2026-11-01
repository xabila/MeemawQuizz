import AVKit
import SwiftUI
import UIKit

/// Bouton natif `AVRoutePickerView` permettant d'ouvrir directement le sélecteur AirPlay iOS/Apple TV.
struct AirPlayRoutePickerButton: UIViewRepresentable {
    var tintColor: UIColor = .black

    func makeUIView(context: Context) -> AVRoutePickerView {
        let picker = AVRoutePickerView()
        picker.tintColor = tintColor
        picker.activeTintColor = UIColor(red: 1.0, green: 0.55, blue: 0.26, alpha: 1.0)
        picker.prioritizesVideoDevices = true
        return picker
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {
        uiView.tintColor = tintColor
    }
}
