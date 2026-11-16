import PhotosUI
import UIKit

final class ColoringFormViewController: UIViewController {

    var onSave: ((Coloring) -> Void)?
    var onProductCreated: ((Product) -> Void)?

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let datePicker = UIDatePicker()
    private let mixingRatioTextField = UITextField()
    private let applicationTimeTextField = UITextField()
    private let notesTextView = UITextView()
    private let photosButton = UIButton(type: .system)
    private let photosCountLabel = UILabel()
    private let productStackView = UIStackView()
    private var productRows: [ColoringProductInputView] = []
    private var availableProducts: [Product]
    private var photos: [Data] = []
    private var regionInputs: [RegionInput] = []

    init(products: [Product] = ColoringMockData.products) {
        availableProducts = products
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("ColoringFormViewController does not support NSCoder initialization")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        title = "Nova coloração"
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelForm)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Salvar",
            style: .done,
            target: self,
            action: #selector(saveColoring)
        )

        configureFields()
        configureStacks()
        buildForm()

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    private func configureFields() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact

        mixingRatioTextField.placeholder = "Ex.: 1:1"
        mixingRatioTextField.borderStyle = .roundedRect
        mixingRatioTextField.autocorrectionType = .no

        applicationTimeTextField.placeholder = "Minutos"
        applicationTimeTextField.text = "30"
        applicationTimeTextField.keyboardType = .numberPad
        applicationTimeTextField.borderStyle = .roundedRect

        notesTextView.font = .preferredFont(forTextStyle: .body)
        notesTextView.layer.borderColor = UIColor.separator.cgColor
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.cornerRadius = 8
        notesTextView.heightAnchor.constraint(equalToConstant: 110).isActive = true

        photosButton.setTitle("Adicionar fotografias", for: .normal)
        photosButton.contentHorizontalAlignment = .leading
        photosButton.addTarget(self, action: #selector(selectPhotos), for: .touchUpInside)

        photosCountLabel.text = "Nenhuma fotografia selecionada"
        photosCountLabel.textColor = .secondaryLabel
        photosCountLabel.font = .preferredFont(forTextStyle: .footnote)

        productStackView.axis = .vertical
        productStackView.spacing = 10
    }

    private func configureStacks() {
        contentStackView.axis = .vertical
        contentStackView.spacing = 24
    }

    private func buildForm() {
        let datePickerContainer = UIStackView(arrangedSubviews: [datePicker])
        datePickerContainer.axis = .vertical
        datePickerContainer.alignment = .center
        contentStackView.addArrangedSubview(makeSection(title: "Data da aplicação", content: datePickerContainer))

        let conditionsStack = UIStackView()
        conditionsStack.axis = .vertical
        conditionsStack.spacing = 16
        for region in [HairRegion.root, .length, .ends] {
            let input = RegionInput(region: region)
            regionInputs.append(input)
            conditionsStack.addArrangedSubview(input.makeView())
        }
        contentStackView.addArrangedSubview(makeSection(title: "Condições do cabelo", content: conditionsStack))

        let addProductButton = UIButton(type: .system)
        addProductButton.setTitle("＋ Adicionar produto", for: .normal)
        addProductButton.contentHorizontalAlignment = .leading
        addProductButton.addTarget(self, action: #selector(addProduct), for: .touchUpInside)
        let productsContent = UIStackView(arrangedSubviews: [productStackView, addProductButton])
        productsContent.axis = .vertical
        productsContent.spacing = 12
        contentStackView.addArrangedSubview(makeSection(title: "Produtos utilizados", content: productsContent))

        let recipeStack = UIStackView(arrangedSubviews: [
            labeledField("Proporção da mistura", field: mixingRatioTextField),
            labeledField("Tempo de aplicação (minutos)", field: applicationTimeTextField)
        ])
        recipeStack.axis = .vertical
        recipeStack.spacing = 14
        contentStackView.addArrangedSubview(makeSection(title: "Mistura e aplicação", content: recipeStack))

        let photosStack = UIStackView(arrangedSubviews: [photosButton, photosCountLabel])
        photosStack.axis = .vertical
        photosStack.spacing = 6
        contentStackView.addArrangedSubview(makeSection(title: "Fotografias", content: photosStack))
        contentStackView.addArrangedSubview(makeSection(title: "Observações", content: notesTextView))
    }

    private func makeSection(title: String, content: UIView) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .headline)

        let stack = UIStackView(arrangedSubviews: [titleLabel, content])
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }

    private func labeledField(_ title: String, field: UIView) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .subheadline)

        let stack = UIStackView(arrangedSubviews: [label, field])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    @objc private func addProduct() {
        let picker = UIAlertController(title: "Adicionar produto", message: "Escolha um produto do catálogo local", preferredStyle: .actionSheet)
        for product in availableProducts {
            let shade = product.shade.map { " · \($0)" } ?? ""
            picker.addAction(UIAlertAction(title: "\(product.brand) \(product.name)\(shade)", style: .default) { [weak self] _ in
                self?.appendProduct(product)
            })
        }
        picker.addAction(UIAlertAction(title: "Cadastrar novo produto…", style: .default) { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                self?.showNewProductForm()
            }
        })
        picker.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        if let popover = picker.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(picker, animated: true)
    }

    private func showNewProductForm() {
        let productViewController = NewProductViewController()
        productViewController.onSave = { [weak self] product in
            guard let self else { return }
            self.availableProducts.append(product)
            self.onProductCreated?(product)
            self.appendProduct(product)
        }

        let navigationController = UINavigationController(rootViewController: productViewController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }

    private func appendProduct(_ product: Product) {
        let row = ColoringProductInputView(product: product)
        row.onRemove = { [weak self, weak row] in
            guard let self, let row else { return }
            self.productRows.removeAll { $0 === row }
            self.productStackView.removeArrangedSubview(row)
            row.removeFromSuperview()
        }
        productRows.append(row)
        productStackView.addArrangedSubview(row)
    }

    @objc private func selectPhotos() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 0
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func updatePhotosCount() {
        photosCountLabel.text = photos.isEmpty
            ? "Nenhuma fotografia selecionada"
            : "\(photos.count) fotografia(s) selecionada(s)"
    }

    @objc private func saveColoring() {
        view.endEditing(true)

        guard !productRows.isEmpty else {
            showValidationMessage("Adicione pelo menos um produto.")
            return
        }
        let products = productRows.compactMap { $0.makeColoringProduct() }
        guard products.count == productRows.count else {
            showValidationMessage("Confira a quantidade informada para cada produto.")
            return
        }
        guard let applicationTime = Int(applicationTimeTextField.text ?? ""), applicationTime > 0 else {
            showValidationMessage("Informe o tempo de aplicação em minutos.")
            return
        }

        let hairBase = HairBase(regions: regionInputs.map { $0.makeCondition() }, photo: nil)
        let coloring = Coloring(
            id: UUID(),
            date: datePicker.date,
            hairBase: hairBase,
            products: products,
            mixingRatio: mixingRatioTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            applicationTime: applicationTime,
            photos: photos,
            notes: notesTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        )
        onSave?(coloring)
    }

    private func showValidationMessage(_ message: String) {
        let alert = UIAlertController(title: "Confira o formulário", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func cancelForm() {
        dismiss(animated: true)
    }

    private final class RegionInput {
        let region: HairRegion
        private let conditionButton = UIButton(type: .system)
        private var selectedCondition: HairCondition = .natural
        private let levelTextField = UITextField()
        private let undertoneTextField = UITextField()
        private let notesTextField = UITextField()

        init(region: HairRegion) {
            self.region = region
        }

        func makeView() -> UIView {
            let titleLabel = UILabel()
            titleLabel.text = regionTitle
            titleLabel.font = .preferredFont(forTextStyle: .subheadline)

            conditionButton.setTitle("Natural ▾", for: .normal)
            conditionButton.contentHorizontalAlignment = .leading
            conditionButton.showsMenuAsPrimaryAction = true
            let conditionOptions: [(String, HairCondition)] = [
                ("Natural", .natural),
                ("Colorido", .colored),
                ("Descolorido", .bleached),
                ("Virgem", .virgin),
                ("Outro", .other)
            ]
            conditionButton.menu = UIMenu(children: conditionOptions.map { title, condition in
                UIAction(title: title) { [weak self] _ in
                    self?.selectedCondition = condition
                    self?.conditionButton.setTitle("\(title) ▾", for: .normal)
                }
            })

            levelTextField.placeholder = "Altura do tom"
            levelTextField.keyboardType = .numberPad
            levelTextField.borderStyle = .roundedRect

            undertoneTextField.placeholder = "Subtom (ex.: dourado)"
            undertoneTextField.borderStyle = .roundedRect

            notesTextField.placeholder = "Observação da região"
            notesTextField.borderStyle = .roundedRect

            let details = UIStackView(arrangedSubviews: [levelTextField, undertoneTextField, notesTextField])
            details.axis = .vertical
            details.spacing = 8

            let stack = UIStackView(arrangedSubviews: [titleLabel, conditionButton, details])
            stack.axis = .vertical
            stack.spacing = 8
            return stack
        }

        func makeCondition() -> HairRegionCondition {
            return HairRegionCondition(
                region: region,
                condition: selectedCondition,
                level: Int(levelTextField.text ?? ""),
                undertone: undertoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
                notes: notesTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
            )
        }

        private var regionTitle: String {
            switch region {
            case .root: return "Raiz"
            case .length: return "Comprimento"
            case .ends: return "Pontas"
            }
        }
    }
}

extension ColoringFormViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        for result in results where result.itemProvider.canLoadObject(ofClass: UIImage.self) {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
                guard let image = object as? UIImage, let data = image.jpegData(compressionQuality: 0.8) else { return }
                DispatchQueue.main.async {
                    self?.photos.append(data)
                    self?.updatePhotosCount()
                }
            }
        }
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
