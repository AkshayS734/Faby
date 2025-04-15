import UIKit

class NutritionSetupViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        button.tintColor = .systemGray3
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        let text = "Does your child have\nany allergies?"
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.1
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        label.attributedText = attributedString
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "It's completely normal if you don't know this"
        label.font = .systemFont(ofSize: 17)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let allergiesFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 12
        return layout
    }()
    
    private lazy var allergiesCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: allergiesFlowLayout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AllergyCell.self, forCellWithReuseIdentifier: "AllergyCell")
        collectionView.register(CustomAllergyCell.self, forCellWithReuseIdentifier: "CustomAllergyCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = UIColor(hex: "#1B4B8A")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 28
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.1
        return button
    }()
    
    private var selectedAllergies: Set<String> = []
    private var customAllergy: String = ""
    private let allergies = ["None", "Peanut", "Egg", "Soy", "Walnut", "Vegan", "Cashew", "Almond", "Custom"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        view.addSubview(closeButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(allergiesCollectionView)
        view.addSubview(nextButton)
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            
            scrollView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            allergiesCollectionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            allergiesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            allergiesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            allergiesCollectionView.heightAnchor.constraint(equalToConstant: 200),
            allergiesCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: view.bounds.width - 48),
            nextButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func nextButtonTapped() {
        var finalAllergies = selectedAllergies
        if !customAllergy.isEmpty {
            finalAllergies.insert(customAllergy)
        }
        
        let nutritionProfile = NutritionProfile(
            allergies: Array(finalAllergies).joined(separator: ", "),
            dietaryRestrictions: "",
            feedingStyle: ""
        )
        
        UserDefaults.standard.set(true, forKey: "nutritionSetupCompleted")
        
        if let encodedData = try? JSONEncoder().encode(nutritionProfile) {
            UserDefaults.standard.set(encodedData, forKey: "babyNutritionProfile")
        }
        
        dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name("NutritionSetupCompleted"), object: nil)
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension NutritionSetupViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allergies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let allergy = allergies[indexPath.item]
        
        if allergy == "Custom" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomAllergyCell", for: indexPath) as! CustomAllergyCell
            cell.delegate = self
            cell.configure(with: customAllergy)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllergyCell", for: indexPath) as! AllergyCell
            cell.configure(with: allergy, isSelected: selectedAllergies.contains(allergy))
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let allergy = allergies[indexPath.item]
        
        if allergy == "Custom" {
            return
        }
        
        if allergy == "None" {
            selectedAllergies.removeAll()
            selectedAllergies.insert("None")
            customAllergy = ""
        } else {
            if selectedAllergies.contains("None") {
                selectedAllergies.remove("None")
            }
            
            if selectedAllergies.contains(allergy) {
                selectedAllergies.remove(allergy)
            } else {
                selectedAllergies.insert(allergy)
            }
        }
        
        collectionView.reloadData()
    }
}

// MARK: - Custom Allergy Cell Delegate
extension NutritionSetupViewController: CustomAllergyCellDelegate {
    func customAllergyDidChange(_ text: String) {
        customAllergy = text
        if !text.isEmpty {
            selectedAllergies.remove("None")
            allergiesCollectionView.reloadData()
        }
    }
}

// MARK: - Allergy Cell
class AllergyCell: UICollectionViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        
        contentView.layer.cornerRadius = 20
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    func configure(with title: String, isSelected: Bool) {
        titleLabel.text = title
        
        if isSelected {
            contentView.backgroundColor = UIColor(hex: "#1B4B8A")
            titleLabel.textColor = .white
            contentView.layer.borderWidth = 0
        } else {
            contentView.backgroundColor = .systemBackground
            titleLabel.textColor = .label
            contentView.layer.borderWidth = 1
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let targetSize = CGSize(width: 1000, height: 40)
        let size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
        let frame = CGRect(origin: attributes.frame.origin, size: size)
        attributes.frame = frame
        return attributes
    }
}

// MARK: - Custom Allergy Cell
protocol CustomAllergyCellDelegate: AnyObject {
    func customAllergyDidChange(_ text: String)
}

class CustomAllergyCell: UICollectionViewCell {
    weak var delegate: CustomAllergyCellDelegate?
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type custom allergy..."
        textField.font = .systemFont(ofSize: 17)
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(textField)
        
        contentView.layer.cornerRadius = 20
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.backgroundColor = .systemBackground
        
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contentView.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func configure(with text: String) {
        textField.text = text
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        delegate?.customAllergyDidChange(textField.text ?? "")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
}

struct NutritionProfile: Codable {
    let allergies: String
    let dietaryRestrictions: String
    let feedingStyle: String
} 