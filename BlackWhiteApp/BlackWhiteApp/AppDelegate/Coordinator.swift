//
//  Coordinator.swift
//  BlackWhiteApp
//
//  Created by Ivan on 11/15/24.
//
import UIKit
import PhotosUI
import Combine

final class Coordinator {
    let window: UIWindow
    
    private var imagePickerSubject: PassthroughSubject<UIImage, Never>?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func activate() {
        let rootViewController = tabBarController
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    private var tabBarController: UITabBarController? {
        let controller = UITabBarController()
        let appearance = UITabBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)
        controller.tabBar.standardAppearance = appearance
        controller.tabBar.scrollEdgeAppearance = appearance
        controller.tabBar.tintColor = .green
        controller.viewControllers = [photoEffectController, settingsController]
        return controller
    }
    
    private var photoEffectController: UIViewController {
        let controller = UINavigationController(rootViewController: PhotoEffect.ViewController(viewModel: PhotoEffect.ViewModel(coordinator: self)))
        controller.tabBarItem.image = UIImage(systemName: "scribble.variable")
        controller.tabBarItem.title = "Photo Effect"
        return controller
    }
    
    private var settingsController: UIViewController {
        let controller = UINavigationController(rootViewController: Settings.ViewController())
        controller.tabBarItem.image = UIImage(systemName: "gearshape")
        controller.tabBarItem.title = "Settings"
        return controller
    }
}

extension Coordinator: ErrorHandler {
    func handleError(_ error: any Error) {
        window.rootViewController?.present(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert), animated: true)
    }
}

extension Coordinator: ImagePickerPresenter {
    func presentImagePicker(subject: PassthroughSubject<UIImage, Never>) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        let pickerViewController = PHPickerViewController(configuration: configuration)
        pickerViewController.delegate = self
        self.imagePickerSubject = subject
        window.rootViewController?.present(pickerViewController, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image , error  in
            if let error {
                self?.handleError(error)
            }
            if let selectedImage = image as? UIImage{
                DispatchQueue.main.async {
                    self?.imagePickerSubject?.send(selectedImage)
                }
            }
        }
    }
}
