//
//  ColoringHistoryViewController.swift
//  RedheadLab
//

import UIKit

final class ColoringHistoryViewController: UIViewController {

    var onColoringSelected: ((Coloring) -> Void)?

    private let colorings: [Coloring]
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    init(colorings: [Coloring] = ColoringMockData.colorings) {
        self.colorings = colorings.sorted { $0.date > $1.date }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("ColoringHistoryViewController does not support NSCoder initialization")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        title = "Histórico de Colorações"
        view.backgroundColor = .systemBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeHistory)
        )

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ColoringGalleryCell.self, forCellWithReuseIdentifier: ColoringGalleryCell.reuseIdentifier)

        if colorings.isEmpty {
            collectionView.backgroundView = makeEmptyStateView()
        }

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func makeEmptyStateView() -> UIView {
        let messageLabel = UILabel()
        messageLabel.text = "Nenhuma coloração registrada ainda."
        messageLabel.textColor = .secondaryLabel
        messageLabel.font = .preferredFont(forTextStyle: .body)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        let containerView = UIView()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -24)
        ])

        return containerView
    }

    @objc private func closeHistory() {
        dismiss(animated: true)
    }
}

extension ColoringHistoryViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colorings.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ColoringGalleryCell.reuseIdentifier,
            for: indexPath
        ) as? ColoringGalleryCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: colorings[indexPath.row], dateFormatter: dateFormatter)
        return cell
    }
}

extension ColoringHistoryViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onColoringSelected?(colorings[indexPath.row])
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let horizontalInsets: CGFloat = 32
        let interitemSpacing: CGFloat = 12
        let itemWidth = (collectionView.bounds.width - horizontalInsets - interitemSpacing) / 2
        return CGSize(width: itemWidth, height: itemWidth + 88)
    }
}

#Preview("Coloring History") {
    ColoringHistoryViewController()
}

#Preview("Empty Coloring History") {
    ColoringHistoryViewController(colorings: [])
}
