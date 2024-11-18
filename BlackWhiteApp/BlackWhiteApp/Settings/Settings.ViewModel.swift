//
//  Settings.ViewModel.swift
//  BlackWhiteApp
//
//  Created by Ivan on 11/18/24.
//
import Combine

extension Settings {
    final class ViewModel {
        typealias SettingsCoordinator = AlertPresenter
        let models: [CellViewModel] = [Cell.ViewModel(title: "About application")]
        
        let selectionIndexSubject: PassthroughSubject<Int, Never> = .init()
        
        private var cancellables: Set<AnyCancellable> = []
        private let coordinator: SettingsCoordinator
        
        init(coordinator: SettingsCoordinator) {
            self.coordinator = coordinator
            
            selectionIndexSubject
                .sink { [weak self] index in
                    guard let self, index == 0 else { return }
                    self.coordinator.presentAlert(with: Constants.aboutApplicationTitle, message: Constants.authorInfo)
                }
                .store(in: &cancellables)
        }
        
        private enum Constants {
            static let aboutApplicationTitle: String = "About application"
            static let authorInfo: String = "Ivan Budovich, iOS Software Engineer"
        }
    }
}
