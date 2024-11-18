//
//  ViewController.swift
//  BlackWhiteApp
//
//  Created by Ivan on 11/15/24.
//

import UIKit

enum Settings { }

extension Settings {
    final class ViewController: UIViewController {
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private let tableView: UITableView = {
            let tableView = UITableView(frame: .zero, style: .insetGrouped)
            tableView.translatesAutoresizingMaskIntoConstraints = false
            return tableView
        }()
        
        private let viewModel: ViewModel
        
        
        init(viewModel: ViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            super.viewDidLoad()
            navigationItem.title = Constants.title
            navigationItem.style = .editor
            view.addSubview(tableView)
            setupTableView()
            setupLayout()
            

        }
        
        private func setupTableView() {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(Settings.Cell.self, forCellReuseIdentifier: Cell.identifier)
        }
        
        private func setupLayout() {
            NSLayoutConstraint.activate([
                tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        }

    }
}

extension Settings.ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = viewModel.models[indexPath.row]
        if cellModel is Settings.Cell.ViewModel {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Settings.Cell.identifier, for: indexPath) as? Settings.Cell,
                  let cellModel = cellModel as? Settings.Cell.ViewModel else {
                return UITableViewCell(style: .default, reuseIdentifier: UITableViewCell.identifier)
            }
            cell.configure(with: cellModel)
            return cell
        } else {
            return UITableViewCell(style: .default, reuseIdentifier: UITableViewCell.identifier)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectionIndexSubject.send(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellModel = viewModel.models[indexPath.row]
        if cellModel is Settings.Cell.ViewModel {
            return Settings.Cell.height
        }
        return .zero
    }
}

extension Settings.ViewController {
    private enum Constants {
        static let title: String = "Settings"
    }
}

extension UITableViewCell {
    static var identifier: String {
        return String(describing: Self.self)
    }
}
