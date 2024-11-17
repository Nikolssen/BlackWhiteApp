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
        
        private var draggableImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.layer.borderWidth = 2
            imageView.layer.borderColor = UIColor.yellow.cgColor
            imageView.layer.masksToBounds = true
            imageView.isHidden = true
            imageView.isUserInteractionEnabled = true
            return imageView
        }()
        
        private var addImageView: UIImageView = {
            let imageView = UIImageView(image: UIImage(systemName: "plus.circle"))
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .lightGray
            return imageView
        }()
        
        private var addImageLabel: UILabel = {
            let label = UILabel()
            label.text = "Tap anywhere to open a photo"
            label.font = .systemFont(ofSize: 16, weight: .semibold)
            label.textColor = .lightGray
            label.numberOfLines = 2
            return label
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
            
            [draggableImageView, addImageView, addImageLabel].forEach {
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
                    
                    if isSelected {
                        view.removeGestureRecognizer(addGestureRecognizer)
                        draggableImageView.image = viewModel.image
                        draggableImageView.frame = .init(origin: .zero, size: .init(width: 400, height: 400))
                        draggableImageView.center = view.center
                        initialCenter = view.center
                    } else {
                        view.addGestureRecognizer(addGestureRecognizer)
                    }
                    
                    addImageView.isHidden = isSelected
                    addImageLabel.isHidden = isSelected
                    draggableImageView.isHidden = !isSelected

                }
                .store(in: &cancellables)
            
            configureLayout()
        }
        
        private func configureLayout() {
            addImageView.translatesAutoresizingMaskIntoConstraints = false
            addImageLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                addImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                addImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                addImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 80),
                addImageView.widthAnchor.constraint(equalTo: addImageView.heightAnchor),
                
                addImageLabel.topAnchor.constraint(equalTo: addImageView.bottomAnchor, constant: 20),
                addImageLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 80),
                addImageLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
                ])
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
        }
        
        @objc private func zoomImage(_ gestureRecognizer: UIPinchGestureRecognizer) {
            guard let view = gestureRecognizer.view else { return }
            
            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
                let transform = view.transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale)
                let size = view.frame.size.applying(transform)
                if min(size.height, size.width) >= 100 {
                    view.frame.size = size
                }
                
                gestureRecognizer.scale = 1.0
            }
        }
        
        @objc private func rotateImage(_ gestureRecognizer: UIRotationGestureRecognizer) {
            guard let view = gestureRecognizer.view else { return }
            
            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
                view.transform = view.transform.rotated(by: gestureRecognizer.rotation)
                gestureRecognizer.rotation = 0
            }
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
}
