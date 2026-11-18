//
//  ColoringDetailViewController.swift
//  RedheadLab
//

import UIKit

final class ColoringDetailViewController: UIViewController {

    private var coloring: Coloring
    private var availableProducts: [Product]
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    var onColoringUpdated: ((Coloring) -> Void)?
    var onColoringDeleted: ((UUID) -> Void)?
    var onProductCreated: ((Product) -> Void)?
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    init(coloring: Coloring, products: [Product] = ColoringMockData.products) {
        self.coloring = coloring
        availableProducts = products
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("ColoringDetailViewController does not support NSCoder initialization")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        title = "Detalhes da coloração"
        view.backgroundColor = .systemBackground
        let editButton = UIBarButtonItem(
            title: "Editar",
            style: .plain,
            target: self,
            action: #selector(editColoring)
        )
        let deleteButton = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(confirmDeletion)
        )
        deleteButton.accessibilityLabel = "Excluir coloração"
        navigationItem.rightBarButtonItems = [deleteButton, editButton]

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.spacing = 24

        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])

        populateContent()
    }

    private func populateContent() {
        contentStackView.addArrangedSubview(makeSection(title: "Data", body: dateFormatter.string(from: coloring.date)))
        contentStackView.addArrangedSubview(makeHairBaseSection())
        contentStackView.addArrangedSubview(makeProductsSection())

        let applicationDetails = [
            coloring.mixingRatio.map { "Proporção da mistura: \($0)" },
            "Tempo de aplicação: \(coloring.applicationTime) minutos"
        ].compactMap { $0 }.joined(separator: "\n")
        contentStackView.addArrangedSubview(makeSection(title: "Aplicação", body: applicationDetails))

        if !coloring.photos.isEmpty {
            contentStackView.addArrangedSubview(makePhotosSection())
        }

        if let notes = coloring.notes, !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            contentStackView.addArrangedSubview(makeSection(title: "Observações", body: notes))
        }
    }

    @objc private func editColoring() {
        let formViewController = ColoringFormViewController(
            products: availableProducts,
            coloringToEdit: coloring
        )

        formViewController.onProductCreated = { [weak self] product in
            guard let self else {
                return
            }

            availableProducts.append(product)
            onProductCreated?(product)
        }

        formViewController.onSave = { [weak self] updatedColoring in
            guard let self else {
                return
            }

            coloring = updatedColoring
            refreshContent()
            onColoringUpdated?(updatedColoring)
            navigationController?.popViewController(animated: true)
        }

        navigationController?.pushViewController(formViewController, animated: true)
    }

    @objc private func confirmDeletion() {
        let alert = UIAlertController(
            title: "Excluir coloração?",
            message: "Esta ação não pode ser desfeita.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Excluir", style: .destructive) { [weak self] _ in
            guard let self else {
                return
            }

            onColoringDeleted?(coloring.id)
            navigationController?.popViewController(animated: true)
        })

        present(alert, animated: true)
    }

    private func refreshContent() {
        for arrangedSubview in contentStackView.arrangedSubviews {
            contentStackView.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }

        populateContent()
    }

    private func makeHairBaseSection() -> UIView {
        let regionNames: [HairRegion: String] = [
            .root: "Raiz",
            .length: "Comprimento",
            .ends: "Pontas"
        ]
        let conditionNames: [HairCondition: String] = [
            .natural: "Natural",
            .colored: "Colorido",
            .bleached: "Descolorido",
            .virgin: "Virgem",
            .other: "Outro"
        ]

        let regionDetails = coloring.hairBase.regions.map { region in
            var lines = ["\(regionNames[region.region] ?? "Região"): \(conditionNames[region.condition] ?? "Não informado")"]
            if let level = region.level {
                lines.append("Altura do tom: \(level)")
            }
            if let undertone = region.undertone, !undertone.isEmpty {
                lines.append("Subtom: \(undertone)")
            }
            if let notes = region.notes, !notes.isEmpty {
                lines.append("Observação: \(notes)")
            }
            return lines.joined(separator: " · ")
        }

        let sectionStackView = UIStackView()
        sectionStackView.axis = .vertical
        sectionStackView.spacing = 8
        sectionStackView.addArrangedSubview(makeTitleLabel("Condição do cabelo"))
        sectionStackView.addArrangedSubview(makeBodyLabel(regionDetails.joined(separator: "\n\n")))

        if let photoData = coloring.hairBase.photo, let image = UIImage(data: photoData) {
            sectionStackView.addArrangedSubview(makeImageView(image: image))
        }

        return sectionStackView
    }

    private func makeProductsSection() -> UIView {
        let sectionStackView = UIStackView()
        sectionStackView.axis = .vertical
        sectionStackView.spacing = 12

        let titleLabel = makeTitleLabel("Produtos utilizados")
        sectionStackView.addArrangedSubview(titleLabel)

        if coloring.products.isEmpty {
            sectionStackView.addArrangedSubview(makeBodyLabel("Nenhum produto registrado"))
        } else {
            for coloringProduct in coloring.products {
                let product = coloringProduct.product
                let shade = product.shade.map { " · \($0)" } ?? ""
                var details = "\(product.brand) \(product.name)\(shade)\nQuantidade: \(formatQuantity(coloringProduct.quantity)) \(coloringProduct.unit.rawValue)"
                if let oxidantVolume = coloringProduct.oxidantVolume {
                    details += "\nVolumagem: \(oxidantVolume) volumes"
                }
                sectionStackView.addArrangedSubview(makeBodyLabel(details))
            }
        }

        return sectionStackView
    }

    private func makePhotosSection() -> UIView {
        let sectionStackView = UIStackView()
        sectionStackView.axis = .vertical
        sectionStackView.spacing = 12
        sectionStackView.addArrangedSubview(makeTitleLabel("Fotografias"))

        for photoData in coloring.photos {
            if let image = UIImage(data: photoData) {
                sectionStackView.addArrangedSubview(makeImageView(image: image))
            }
        }

        return sectionStackView
    }

    private func makeSection(title: String, body: String) -> UIView {
        let sectionStackView = UIStackView()
        sectionStackView.axis = .vertical
        sectionStackView.spacing = 8
        sectionStackView.addArrangedSubview(makeTitleLabel(title))
        sectionStackView.addArrangedSubview(makeBodyLabel(body))
        return sectionStackView
    }

    private func makeTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        return label
    }

    private func makeBodyLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }

    private func makeImageView(image: UIImage) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        return imageView
    }

    private func formatQuantity(_ quantity: Double) -> String {
        quantity.formatted(.number.locale(Locale(identifier: "pt_BR")))
    }
}

#Preview("Coloring Details") {
    if let coloring = ColoringMockData.colorings.first {
        return UINavigationController(rootViewController: ColoringDetailViewController(coloring: coloring))
    }
    return UINavigationController(rootViewController: ColoringHistoryViewController(colorings: []))
}
