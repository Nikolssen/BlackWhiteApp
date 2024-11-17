//
//  PhotoEffect.ViewModel.swift
//  BlackWhiteApp
//
//  Created by Ivan on 11/16/24.
//

import Foundation
import Combine
import UIKit

extension PhotoEffect {
    
    final class ViewModel {
        
        typealias PhotoEffectCoordinator = ImagePickerPresenter & ErrorHandler
        private let coordinator: PhotoEffectCoordinator
        var image: UIImage?
        
        private var cancellables: Set<AnyCancellable> = []
        
        let isImageSelectedSubject: CurrentValueSubject<Bool, Never> = .init(false)
        let requestImageSubject: PassthroughSubject<Void, Never> = .init()
        
        private let imageSelectionSubject: PassthroughSubject<UIImage, Never> = .init()
        
        init(coordinator: PhotoEffectCoordinator) {
            self.coordinator = coordinator
            
            requestImageSubject
                .sink { [weak self] in
                    guard let self else { return }
                    coordinator.presentImagePicker(subject: imageSelectionSubject)
                }
                .store(in: &cancellables)
            
            imageSelectionSubject
                .sink { [weak self] image in
                    guard let self else { return }
                    self.image = image
                    isImageSelectedSubject.send(true)
                }
                .store(in: &cancellables)
            
        }
    }
    
}

