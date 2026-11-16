import UIKit

final class ColoringProductInputView: UIView {

    let id = UUID()
    let product: Product
    var onRemove: (() -> Void)?

    private let quantityTextField = UITextField()
    private let unitControl = UISegmentedControl(items: ["g", "ml", "un"])
    private let oxidantVolumeTextField = UITextField()

    init(product: Product) {
        self.product = product
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("ColoringProductInputView does not support NSCoder initialization")
    }

    func makeColoringProduct() -> ColoringProduct? {
        let normalizedQuantity = (quantityTextField.text ?? "").replacingOccurrences(of: ",", with: ".")
        guard let quantity = Double(normalizedQuantity), quantity > 0 else { return nil }

        let unit: MeasurementUnit
        switch unitControl.selectedSegmentIndex {
        case 0: unit = .grams
        case 1: unit = .milliliters
        default: unit = .units
        }

        let volume = Int(oxidantVolumeTextField.text ?? "")
        return ColoringProduct(
            id: id,
            product: product,
            quantity: quantity,
            unit: unit,
            oxidantVolume: product.type == .oxidant ? volume : nil
        )
    }

    private func setupView() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 12

        let nameLabel = UILabel()
        let shade = product.shade.map { " · \($0)" } ?? ""
        nameLabel.text = "\(product.brand) \(product.name)\(shade)"
        nameLabel.font = .preferredFont(forTextStyle: .subheadline)
        nameLabel.numberOfLines = 0

        let removeButton = UIButton(type: .system)
        removeButton.setImage(UIImage(systemName: "trash"), for: .normal)
        removeButton.accessibilityLabel = "Remover produto"
        removeButton.addTarget(self, action: #selector(removeProduct), for: .touchUpInside)

        quantityTextField.placeholder = "Quantidade"
        quantityTextField.keyboardType = .decimalPad
        quantityTextField.borderStyle = .roundedRect
        quantityTextField.widthAnchor.constraint(equalToConstant: 110).isActive = true

        unitControl.selectedSegmentIndex = defaultUnitIndex

        oxidantVolumeTextField.placeholder = "Vol. oxidante"
        oxidantVolumeTextField.keyboardType = .numberPad
        oxidantVolumeTextField.borderStyle = .roundedRect
        oxidantVolumeTextField.widthAnchor.constraint(equalToConstant: 120).isActive = true
        oxidantVolumeTextField.isHidden = product.type != .oxidant

        let header = UIStackView(arrangedSubviews: [nameLabel, removeButton])
        header.axis = .horizontal
        header.alignment = .center
        header.spacing = 8

        let quantityAndUnit = UIStackView(arrangedSubviews: [quantityTextField, unitControl])
        quantityAndUnit.axis = .horizontal
        quantityAndUnit.alignment = .center
        quantityAndUnit.spacing = 8

        let details = UIStackView(arrangedSubviews: [quantityAndUnit, oxidantVolumeTextField])
        details.axis = .vertical
        details.alignment = .center
        details.spacing = 8
        quantityAndUnit.widthAnchor.constraint(equalTo: details.widthAnchor).isActive = true
        unitControl.setContentHuggingPriority(.defaultLow, for: .horizontal)
        unitControl.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [header, details])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    private var defaultUnitIndex: Int {
        switch product.type {
        case .oxidant: return 1
        case .other: return 2
        case .permanentDye, .semiPermanentDye: return 0
        }
    }

    @objc private func removeProduct() {
        onRemove?()
    }
}
