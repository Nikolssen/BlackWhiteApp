//
//  ImageFilter.swift
//  BlackWhiteApp
//
//  Created by Ivan on 11/17/24.
//
import CoreImage.CIFilterBuiltins

struct ImageFilter {
    let filter: CIFilter
    let title: String
}

extension ImageFilter {
    static var availableFilters: [ImageFilter] {
        let monoFilter = CIFilter.photoEffectMono()
        monoFilter.extrapolate = true
        
        let monochromeFilter = CIFilter.colorMonochrome()
        monochromeFilter.color = .blue
        monochromeFilter.intensity = 0.5
        
        let sepiaFilter = CIFilter.sepiaTone()
        sepiaFilter.intensity = 0.5
        
        let sobelEffect = CIFilter.sobelGradients()
        
        return [
            ImageFilter(filter: monoFilter, title: "Mono"),
            ImageFilter(filter: monochromeFilter, title: "Blue Monochrome"),
            ImageFilter(filter: sepiaFilter, title: "Sepia"),
            ImageFilter(filter: sobelEffect, title: "Sobel Operator")
        ]
    }
}
