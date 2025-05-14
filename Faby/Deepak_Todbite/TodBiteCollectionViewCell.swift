import UIKit

// Define the delegate protocol
protocol TodBiteCollectionViewCellDelegate: AnyObject {
    func didTapAddButton(for item: FeedingMeal, in category: BiteType)
}

class TodBiteCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Components
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var nutritionLabel: UILabel!
    @IBOutlet weak var myImageView: UIImageView!
    private let addButton = UIButton(type: .system)
    private let cardContentView = UIView()
    
    // MARK: - Properties
    weak var delegate: TodBiteCollectionViewCellDelegate?
    private var currentItem: FeedingMeal?
    private var currentCategory: BiteType?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardView()
        setupCellAppearance()
        setupAddButton()
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update shadow path based on actual bounds
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 12).cgPath
    }

    // MARK: - Cell Setup
    private func setupCardView() {
        // Setup main content view - this will be our card
        cardContentView.backgroundColor = .white
        cardContentView.layer.cornerRadius = 12
        cardContentView.layer.masksToBounds = true
        cardContentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add enhanced, more prominent shadow to the cell
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 0.7
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 12).cgPath
        self.layer.masksToBounds = false
        self.layer.rasterizationScale = UIScreen.main.scale
        self.layer.shouldRasterize = true // Improves shadow performance
        
        contentView.addSubview(cardContentView)
        
        NSLayoutConstraint.activate([
            cardContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setupCellAppearance() {
        // Configure Image View
        myImageView.clipsToBounds = true
        myImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        myImageView.layer.cornerRadius = 12
        myImageView.contentMode = .scaleAspectFill
        myImageView.backgroundColor = .lightGray

        // Configure Food Name Label
        foodNameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        foodNameLabel.textAlignment = .left
        foodNameLabel.textColor = .black
        foodNameLabel.lineBreakMode = .byTruncatingTail
        foodNameLabel.numberOfLines = 1

        // Configure Nutrition Label
        nutritionLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        nutritionLabel.textAlignment = .left
        nutritionLabel.textColor = .darkGray
        nutritionLabel.lineBreakMode = .byTruncatingTail
        nutritionLabel.numberOfLines = 1
    }

    private func setupAddButton() {
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = .white
        addButton.backgroundColor = UIColor.darkGray
        addButton.layer.cornerRadius = 5
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a subtle shadow effect on the button
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        addButton.layer.shadowRadius = 1
        addButton.layer.shadowOpacity = 0.2

        contentView.addSubview(addButton)

        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: cardContentView.trailingAnchor, constant: -12),
            addButton.centerYAnchor.constraint(equalTo: foodNameLabel.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 20),
            addButton.heightAnchor.constraint(equalToConstant: 20)
        ])

        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        foodNameLabel.translatesAutoresizingMaskIntoConstraints = false
        nutritionLabel.translatesAutoresizingMaskIntoConstraints = false
        myImageView.translatesAutoresizingMaskIntoConstraints = false

        cardContentView.addSubview(myImageView)
        cardContentView.addSubview(foodNameLabel)
        cardContentView.addSubview(nutritionLabel)

        NSLayoutConstraint.activate([
            // Image View Constraints - make it fill the top part of the card
            myImageView.topAnchor.constraint(equalTo: cardContentView.topAnchor),
            myImageView.leadingAnchor.constraint(equalTo: cardContentView.leadingAnchor),
            myImageView.trailingAnchor.constraint(equalTo: cardContentView.trailingAnchor),
            myImageView.heightAnchor.constraint(equalTo: cardContentView.heightAnchor, multiplier: 0.7),

            // Food Name Label Constraints
            foodNameLabel.topAnchor.constraint(equalTo: myImageView.bottomAnchor, constant: 8),
            foodNameLabel.leadingAnchor.constraint(equalTo: cardContentView.leadingAnchor, constant: 12),
            foodNameLabel.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -8),

            // Nutrition Label Constraints
            nutritionLabel.topAnchor.constraint(equalTo: foodNameLabel.bottomAnchor, constant: 2),
            nutritionLabel.leadingAnchor.constraint(equalTo: cardContentView.leadingAnchor, constant: 12),
            nutritionLabel.trailingAnchor.constraint(equalTo: cardContentView.trailingAnchor, constant: -12),
            nutritionLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardContentView.bottomAnchor, constant: -8)
        ])
    }
    func updateButtonState(_ isAdded: Bool) {
        if isAdded {
            addButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            addButton.backgroundColor = UIColor.systemGreen
        } else {
            addButton.setImage(UIImage(systemName: "plus"), for: .normal)
            addButton.backgroundColor = UIColor.systemBlue
        }
    }


    // MARK: - Configure Cell
    func configure(with item: FeedingMeal, category: BiteType, isAdded: Bool) {
        self.currentItem = item
        self.currentCategory = category

        // Update UI with item details
        foodNameLabel.text = item.name
        nutritionLabel.text = item.description
        
        // Image loading with proper error handling
        myImageView.image = UIImage(named: "placeholder")
        
        if let url = URL(string: item.image_url) {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self,
                      error == nil,
                      let data = data,
                      let image = UIImage(data: data) else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.myImageView.image = image
                }
            }
            task.resume()
        }

        // Update button state (Plus or Tick)
        updateButtonState(isAdded)
    }

    // MARK: - Button Action
    @objc private func addButtonTapped() {
        guard let item = currentItem, let category = currentCategory else { return }
        delegate?.didTapAddButton(for: item, in: category)
    }
}
