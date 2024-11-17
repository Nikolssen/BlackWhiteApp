//
//  ImagePickerPresenter.swift
//  BlackWhiteApp
//
//  Created by Ivan on 11/17/24.
//
import UIKit
import PhotosUI
import Combine

protocol ImagePickerPresenter: PHPickerViewControllerDelegate {
    func presentImagePicker(subject: PassthroughSubject<UIImage, Never>)
}
