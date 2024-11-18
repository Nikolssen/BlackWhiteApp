//
//  ImageProcessor.swift
//  BlackWhiteApp
//
//  Created by Ivan on 11/18/24.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import Combine

final class ImageProcessor {
    
    private var currentFilter: CIFilter?
    
    let inputSubject: PassthroughSubject<UIImage, Never> = .init()
    let selectedFilterSubject: PassthroughSubject<CIFilter, Never> = .init()
    let outputSubject: PassthroughSubject<UIImage, Never> = .init()
    
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        selectedFilterSubject.sink { [weak self] filter in
            self?.currentFilter = filter
        }
        .store(in: &cancellables)
        
        inputSubject
            .combineLatest(selectedFilterSubject)
            .sink { [weak self] (image, filter) in
            guard let self, let ciImage = CIImage(image: image) else { return }
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            if let result = filter.outputImage {
                outputSubject.send(UIImage(ciImage: result, scale: image.scale, orientation: image.imageOrientation))
            }
        }
        .store(in: &cancellables)
        
    }
}
