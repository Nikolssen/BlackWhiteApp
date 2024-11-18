//
//  Settings.Cell.swift
//  BlackWhiteApp
//
//  Created by Ivan on 11/18/24.
//
import UIKit

protocol CellViewModel { }

extension Settings {
    class Cell: UITableViewCell {
        
        static let height: CGFloat = 44
        
        struct ViewModel: CellViewModel {
            let title: String
        }
        
        func configure(with viewModel: ViewModel) {
            var configuration = defaultContentConfiguration()
            configuration.text = viewModel.title
            self.contentConfiguration = configuration
        }
    }
}
