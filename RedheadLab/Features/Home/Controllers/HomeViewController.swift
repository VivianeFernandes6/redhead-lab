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
    private var colorings = ColoringMockData.colorings
    private var products = ColoringMockData.products

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
        saveButton.addTarget(self, action: #selector(showColoringForm), for: .touchUpInside)
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
        let historyViewController = ColoringHistoryViewController(colorings: colorings)
        let navigationController = UINavigationController(rootViewController: historyViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }

    @objc private func showColoringForm() {
        let formViewController = ColoringFormViewController(products: products)
        formViewController.onProductCreated = { [weak self] product in
            self?.products.append(product)
        }
        formViewController.onSave = { [weak self] coloring in
            self?.colorings.insert(coloring, at: 0)
            self?.dismiss(animated: true)
        }

        let navigationController = UINavigationController(rootViewController: formViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}

#Preview {
    HomeViewController()
}
