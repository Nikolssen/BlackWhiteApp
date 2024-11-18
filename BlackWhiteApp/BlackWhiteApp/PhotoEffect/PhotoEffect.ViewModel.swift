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
    final class ViewModel: ErrorHandler {
        
        typealias PhotoEffectCoordinator = ImagePickerPresenter & ErrorHandler
        private let coordinator: PhotoEffectCoordinator
        var image: UIImage?
        var processedImage: UIImage?
        
        private var cancellables: Set<AnyCancellable> = []
        
        let isImageSelectedSubject: CurrentValueSubject<Bool, Never> = .init(false)
        let requestImageSubject: PassthroughSubject<Void, Never> = .init()
        let saveImageSubject: PassthroughSubject<Void, Never> = .init()
        let filterSelectionIndexSubject: PassthroughSubject<Int, Never> = .init()
        
        private let imageSelectionSubject: PassthroughSubject<UIImage, Never> = .init()
        private let imageProcessor: ImageProcessor = .init()
        
        private let filters: [ImageFilter] = ImageFilter.availableFilters
        
        var filterTitles: [String] {
            filters.map(\.title)
        }
        
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
                    processedImage = nil
                    isImageSelectedSubject.send(true)
                }
                .store(in: &cancellables)
            
            isImageSelectedSubject
                .sink { [weak self] isSelected in
                    guard let self else { return }
                    if !isSelected {
                        image = nil
                        processedImage = nil
                    }
                }
                .store(in: &cancellables)

            filterSelectionIndexSubject
                .sink { [weak self] index in
                    guard let self, let image else { return }
                    if let filter = filters[index].filter {
                        imageProcessor.selectedFilterSubject.send(filter)
                        imageProcessor.inputSubject.send(image)
                    } else {
                        processedImage = nil
                        isImageSelectedSubject.send(true)
                    }

                }
                .store(in: &cancellables)
            
            imageProcessor.outputSubject
                .sink { [weak self] image in
                    guard let self else { return }
                    processedImage = image
                    isImageSelectedSubject.send(true)
                }
                .store(in: &cancellables)
            
            //imageProcessor.selectedFilterSubject.send(CIFilter.colorMonochrome())
            
        }
        func handleError(_ error: any Error) {
            coordinator.handleError(error)
        }
    }
    
}

