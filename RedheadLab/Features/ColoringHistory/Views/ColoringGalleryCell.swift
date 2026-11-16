//
//  ColoringGalleryCell.swift
//  RedheadLab
//

import UIKit

final class ColoringGalleryCell: UICollectionViewCell {

    static let reuseIdentifier = "ColoringGalleryCell"

    private let coloringImageView = UIImageView()
    private let dateLabel = UILabel()
    private let productsLabel = UILabel()
    private let contentStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("ColoringGalleryCell does not support NSCoder initialization")
    }

    func configure(with coloring: Coloring, dateFormatter: DateFormatter) {
        dateLabel.text = dateFormatter.string(from: coloring.date)
        productsLabel.text = productSummary(for: coloring.products)

        if let photoData = coloring.photos.first, let image = UIImage(data: photoData) {
            coloringImageView.image = image
            coloringImageView.tintColor = nil
            coloringImageView.backgroundColor = .clear
            coloringImageView.contentMode = .scaleAspectFill
        } else {
            coloringImageView.image = UIImage(systemName: "photo")
            coloringImageView.tintColor = .secondaryLabel
            coloringImageView.backgroundColor = .secondarySystemBackground
            coloringImageView.contentMode = .center
        }
    }

    private func setupView() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true

        coloringImageView.layer.cornerRadius = 8
        coloringImageView.clipsToBounds = true
        coloringImageView.translatesAutoresizingMaskIntoConstraints = false

        dateLabel.font = .preferredFont(forTextStyle: .headline)
        dateLabel.textColor = .label

        productsLabel.font = .preferredFont(forTextStyle: .caption1)
        productsLabel.textColor = .secondaryLabel
        productsLabel.numberOfLines = 3

        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.spacing = 8
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(coloringImageView)
        contentStackView.addArrangedSubview(dateLabel)
        contentStackView.addArrangedSubview(productsLabel)

        contentView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            coloringImageView.heightAnchor.constraint(equalTo: coloringImageView.widthAnchor)
        ])
    }

    private func productSummary(for products: [ColoringProduct]) -> String {
        guard !products.isEmpty else {
            return "Nenhum produto registrado"
        }

        return products.map { coloringProduct in
            let product = coloringProduct.product
            let shade = product.shade.map { " · \($0)" } ?? ""
            return "\(product.brand) \(product.name)\(shade)"
        }
        .joined(separator: "\n")
    }
}

#Preview("Coloring Gallery Item") {
    let cell = ColoringGalleryCell(frame: CGRect(x: 0, y: 0, width: 180, height: 270))

    if let coloring = ColoringMockData.colorings.first {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateStyle = .medium
        cell.configure(with: coloring, dateFormatter: formatter)
    }

    return cell
}




