import UIKit

protocol TodBiteCollectionViewCellDelegate: AnyObject {
    func didTapAddButton(for item: Item, in category: CategoryType)
}

class TodBiteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var nutritionLabel: UILabel!
    @IBOutlet weak var myImageView: UIImageView!
    private let addButton = UIButton(type: .system)

    weak var delegate: TodBiteCollectionViewCellDelegate?

    private var currentItem: Item?
    private var currentCategory: CategoryType?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true

        myImageView.layer.cornerRadius = 12
        myImageView.layer.masksToBounds = true

        foodNameLabel.font = UIFont.boldSystemFont(ofSize: foodNameLabel.font.pointSize)

        setupAddButton()
    }

    private func setupAddButton() {
        addButton.setImage(UIImage(systemName: "plus.square.fill"), for: .normal)
        addButton.tintColor = .white
        addButton.backgroundColor = .clear
        addButton.layer.cornerRadius = 15
        addButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(addButton)

        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: myImageView.trailingAnchor, constant: -5),
            addButton.bottomAnchor.constraint(equalTo: myImageView.bottomAnchor, constant: -5),
            addButton.widthAnchor.constraint(equalToConstant: 30),
            addButton.heightAnchor.constraint(equalToConstant: 30)
        ])

        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }

    func configure(with item: Item, category: CategoryType) {
        self.currentItem = item
        self.currentCategory = category

        foodNameLabel.text = item.name
        nutritionLabel.text = item.description
        myImageView.image = UIImage(named: item.image)
    }

    @objc private func addButtonTapped() {
        guard let item = currentItem, let category = currentCategory else { return }
        delegate?.didTapAddButton(for: item, in: category)
    }
}
