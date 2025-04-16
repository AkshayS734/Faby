import UIKit

class TodayBitesViewController: UIViewController {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Today's Bites >"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.clipsToBounds = false
        // Add shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "todayBite")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No meal plan added yet"
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addMealPlanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Meal Plan", for: .normal)
        button.backgroundColor = UIColor(red: 87/255, green: 197/255, blue: 146/255, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.layer.cornerRadius = 25  // More rounded corners
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1.0) // Light gray background
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(cardView)
        
        cardView.addSubview(emptyStateImageView)
        cardView.addSubview(emptyLabel)
        cardView.addSubview(addMealPlanButton)
        
        NSLayoutConstraint.activate([
            // Container constraints
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Title constraints
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Card constraints
            cardView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            cardView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            cardView.heightAnchor.constraint(equalToConstant: 280), // Fixed height for the card
            
            // Image constraints
            emptyStateImageView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            emptyStateImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 40),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 120),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Label constraints
            emptyLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            // Button constraints
            addMealPlanButton.topAnchor.constraint(equalTo: emptyLabel.bottomAnchor, constant: 20),
            addMealPlanButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            addMealPlanButton.widthAnchor.constraint(equalToConstant: 200),
            addMealPlanButton.heightAnchor.constraint(equalToConstant: 50),
            addMealPlanButton.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -20)
        ])
        
        addMealPlanButton.addTarget(self, action: #selector(addMealPlanTapped), for: .touchUpInside)
    }
    
    @objc private func addMealPlanTapped() {
        // Handle add meal plan button tap
        // You can present your meal plan creation view controller here
    }
} 