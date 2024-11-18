//
//  PhotoEffect.ViewController.swift
//  BlackWhiteApp
//
//  Created by Ivan on 11/15/24.
//

import UIKit
import Combine

enum PhotoEffect { }

extension PhotoEffect {
    final class ViewController: UIViewController {

        private let draggableImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.layer.borderWidth = 2
            imageView.layer.borderColor = UIColor.black.cgColor
            imageView.layer.masksToBounds = true
            imageView.isHidden = true
            imageView.isUserInteractionEnabled = true
            return imageView
        }()
        
        private let addImageView: UIImageView = {
            let imageView = UIImageView(image: UIImage(systemName: Constants.addImageName))
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .lightGray
            return imageView
        }()
        
        private let addImageLabel: UILabel = {
            let label = UILabel()
            label.text = Constants.addTitle
            label.font = .systemFont(ofSize: 16, weight: .semibold)
            label.textColor = .lightGray
            label.numberOfLines = 2
            return label
        }()
        
        private let toolBar: UIToolbar = {
            let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Constants.toolBarHeight))
            toolbar.barTintColor = .white
            toolbar.isTranslucent = true
            toolbar.tintColor = .black
            return toolbar
        }()
        
        private var addGestureRecognizer: UITapGestureRecognizer?
        
        private let viewModel: ViewModel
        private var cancellables: Set<AnyCancellable> = []
        
        private var initialCenter: CGPoint = .zero
        
        init(viewModel: ViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            navigationItem.title = Constants.photoEffectTitle
            navigationItem.style = .editor
            
            [draggableImageView, addImageView, addImageLabel, toolBar].forEach {
                view.addSubview($0)
            }
            
            let addGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addImage))
            self.addGestureRecognizer = addGestureRecognizer
            
            let moveGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveImage))
            moveGestureRecognizer.delegate = self
            draggableImageView.addGestureRecognizer(moveGestureRecognizer)
            
            let scaleGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(zoomImage))
            scaleGestureRecognizer.delegate = self
            draggableImageView.addGestureRecognizer(scaleGestureRecognizer)
            
            let rotationGestureRecognzier = UIRotationGestureRecognizer(target: self, action: #selector(rotateImage))
            rotationGestureRecognzier.delegate = self
            draggableImageView.addGestureRecognizer(rotationGestureRecognzier)
        
            viewModel.isImageSelectedSubject
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isSelected in
                    guard let self else { return }
                    
                    if isSelected, let image = viewModel.processedImage ?? viewModel.image {
                        view.removeGestureRecognizer(addGestureRecognizer)
                        let isProcessed = viewModel.processedImage != nil
                        draggableImageView.image = image
                       
                        if !isProcessed {
                            draggableImageView.transform = .identity
                            let ratio = image.size.width / image.size.height
                            
                            if let bounds = view.window?.screen.bounds, bounds.width != 0 {
                                draggableImageView.frame = .init(origin: .zero, size: .init(width: bounds.width, height: bounds.width / ratio))
                            } else {
                                draggableImageView.frame = .init(origin: .zero, size: .init(width: Constants.defaultImageWidth, height: Constants.defaultImageWidth / ratio))
                            }

                            draggableImageView.center = view.center
                            initialCenter = view.center
                        }

                    } else {
                        view.addGestureRecognizer(addGestureRecognizer)
                        draggableImageView.image = nil
                    }
                    
                    addImageView.isHidden = isSelected
                    addImageLabel.isHidden = isSelected
                    draggableImageView.isHidden = !isSelected
                    toolBar.isHidden = !isSelected

                }
                .store(in: &cancellables)
            
            configureLayout()
            configureToolBar()
        }
        
        private func configureLayout() {
            addImageView.translatesAutoresizingMaskIntoConstraints = false
            addImageLabel.translatesAutoresizingMaskIntoConstraints = false
            toolBar.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                addImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                addImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                addImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.addElementsHorizontalInset),
                addImageView.widthAnchor.constraint(equalTo: addImageView.heightAnchor),
                
                addImageLabel.topAnchor.constraint(equalTo: addImageView.bottomAnchor, constant: Constants.addElementsInterspace),
                addImageLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.addElementsHorizontalInset),
                addImageLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                
                toolBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                toolBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                toolBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
                ])
        }
        
        private func configureToolBar() {
            
            let actions = viewModel.filterTitles.enumerated().map { (index, title) in
                UIAction(title: title, handler: { [index, weak self] _ in
                    self?.viewModel.filterSelectionIndexSubject.send(index)
                })
            }
            
            let menuItem = UIBarButtonItem(image: UIImage(systemName: Constants.effectImageName), menu: UIMenu.init(title: Constants.effectTitle, children: actions))
            
            let items = [
                UIBarButtonItem(title: Constants.clearTitle, image: nil, target: self, action: #selector(clear)),
                UIBarButtonItem.flexibleSpace(),
                menuItem,
                UIBarButtonItem.flexibleSpace(),
                UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
            ]
            
            toolBar.setItems(items, animated: true)
        }
        
        @objc private func save() {
            if let image = viewModel.processedImage ?? viewModel.image {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(savedImage), nil)
            }
        }
        
        @objc private func savedImage(image: UIImage, error: Error?, context: UnsafeMutableRawPointer?) {
            if error != nil {
                viewModel.handleError(SaveError.defaultError)
            }
        }
        
        @objc private func clear() {
            viewModel.isImageSelectedSubject.send(false)
        }
        
        @objc private func addImage() {
            viewModel.requestImageSubject.send()
        }
        
        @objc private func moveImage(_ gestureRecognizer: UIPanGestureRecognizer) {
            guard let view = gestureRecognizer.view else { return }
            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
                let translation = gestureRecognizer.translation(in: view.superview)
                let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
                view.center = newCenter
            }
            if gestureRecognizer.state == .ended {
                initialCenter = view.center
            }
        }
        
        @objc private func zoomImage(_ gestureRecognizer: UIPinchGestureRecognizer) {
            guard let view = gestureRecognizer.view else { return }
            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
                let transform = view.transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale)
                if transform.a < Constants.maxZoomScale && transform.a > Constants.minZoomScale {
                    view.transform = transform
                }
            }
            gestureRecognizer.scale = 1.0
        }
        
        @objc private func rotateImage(_ gestureRecognizer: UIRotationGestureRecognizer) {
            guard let view = gestureRecognizer.view else { return }
            
            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
                view.transform = view.transform.rotated(by: gestureRecognizer.rotation)
            }
            gestureRecognizer.rotation = 0
        }
    }
}

extension PhotoEffect.ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    private enum Constants {
        static let maxZoomScale: CGFloat = 4
        static let minZoomScale: CGFloat = 0.25
        
        static let addElementsHorizontalInset: CGFloat = 80
        static let addElementsInterspace: CGFloat = 20
        static let defaultImageWidth: CGFloat = 400
        static let toolBarHeight: CGFloat = 35
        
        static let addTitle: String = "Tap anywhere to open a photo"
        static let clearTitle: String = "Clear"
        static let effectTitle: String = "Effect"
        static let photoEffectTitle = "Photo Effect"
        
        static let effectImageName: String = "wand.and.sparkles"
        static let addImageName: String = "plus.circle"
    }
}

enum SaveError: LocalizedError {
    case defaultError
    
    var errorDescription: String? {
        return "Error saving photo. Please, check the application permissions and try again"
    }
}
