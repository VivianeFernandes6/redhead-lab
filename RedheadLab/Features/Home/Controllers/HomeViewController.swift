//
//  HomeViewController.swift
//  RedheadLab
//
//  Created by Viviane Fernandes on 12/11/26.
//

import UIKit

final class HomeViewController: UIViewController {

    private let titleLabel = UILabel()
    private let saveButton = UIButton(type: .system)
    private let viewButton = UIButton(type: .system)
    private let contentStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    private func setupView() {
        view.backgroundColor = .systemBackground

        configureElements()
        addElements()
        setupConstraints()
    }

    private func configureElements() {
        titleLabel.text = "Redhead Lab"
        titleLabel.textAlignment = .center
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        saveButton.setTitle("Guardar", for: .normal)
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        viewButton.setTitle("Ver", for: .normal)
        viewButton.addTarget(self, action: #selector(showColoringHistory), for: .touchUpInside)
        viewButton.translatesAutoresizingMaskIntoConstraints = false

        contentStackView.axis = .vertical
        contentStackView.alignment = .center
        contentStackView.spacing = 16
        contentStackView.setCustomSpacing(40, after: titleLabel)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func addElements() {
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(saveButton)
        contentStackView.addArrangedSubview(viewButton)
        view.addSubview(contentStackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func showColoringHistory() {
        let historyViewController = ColoringHistoryViewController()
        let navigationController = UINavigationController(rootViewController: historyViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}

#Preview {
    HomeViewController()
}
