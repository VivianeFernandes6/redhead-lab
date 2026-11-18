import UIKit

final class NewProductViewController: UIViewController {

    var onSave: ((Product) -> Void)?

    private let brandTextField = UITextField()
    private let nameTextField = UITextField()
    private let shadeTextField = UITextField()
    private let typeButton = UIButton(type: .system)
    private var selectedType: ProductType?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        title = "Novo produto"
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancel)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Adicionar",
            style: .done,
            target: self,
            action: #selector(saveProduct)
        )

        configureFields()
        let fieldsStack = UIStackView(arrangedSubviews: [
            labeledField("Marca", field: brandTextField),
            labeledField("Nome do produto", field: nameTextField),
            labeledField("Tonalidade (opcional)", field: shadeTextField),
            labeledField("Tipo de produto", field: typeButton)
        ])
        fieldsStack.axis = .vertical
        fieldsStack.spacing = 18
        fieldsStack.translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(fieldsStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            fieldsStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            fieldsStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            fieldsStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            fieldsStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    private func configureFields() {
        configureTextField(brandTextField, placeholder: "Ex.: Wella")
        configureTextField(nameTextField, placeholder: "Ex.: Koleston Perfect")
        configureTextField(shadeTextField, placeholder: "Ex.: 7/4")

        typeButton.setTitle("Selecionar tipo", for: .normal)
        typeButton.contentHorizontalAlignment = .leading
        typeButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        typeButton.showsMenuAsPrimaryAction = true

        let options: [(String, ProductType)] = [
            ("Coloração permanente", .permanentDye),
            ("Coloração semipermanente", .semiPermanentDye),
            ("Oxidante", .oxidant),
            ("Outro", .other)
        ]
        typeButton.menu = UIMenu(children: options.map { title, type in
            UIAction(title: title) { [weak self] _ in
                self?.selectedType = type
                self?.typeButton.setTitle("\(title) ▾", for: .normal)
            }
        })
    }

    private func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
    }

    private func labeledField(_ title: String, field: UIView) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .subheadline)

        let stack = UIStackView(arrangedSubviews: [label, field])
        stack.axis = .vertical
        stack.spacing = 7
        return stack
    }

    @objc private func saveProduct() {
        view.endEditing(true)

        let brand = brandTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !brand.isEmpty, !name.isEmpty, let selectedType else {
            showValidationMessage("Informe a marca, o nome e o tipo do produto.")
            return
        }

        let shade = shadeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let product = Product(
            id: UUID(),
            brand: brand,
            name: name,
            shade: shade?.isEmpty == true ? nil : shade,
            type: selectedType
        )
        onSave?(product)
        navigationController?.dismiss(animated: true)
    }

    private func showValidationMessage(_ message: String) {
        let alert = UIAlertController(title: "Confira o produto", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func cancel() {
        navigationController?.dismiss(animated: true)
    }
}

#Preview("New Product Form") {
    UINavigationController(rootViewController: NewProductViewController())
}
