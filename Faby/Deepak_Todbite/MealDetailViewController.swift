import UIKit

// MARK: - MealDetailViewController
class MealDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - UI Components
    private let topImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let likeButton = UIButton()
    private let nutritionLabel = UILabel() // New Feature
    private let tableView = UITableView()

    // MARK: - Data
    var selectedItem: FeedingMeal!
    var sectionItems: [FeedingMeal] = []
    private var isLiked = false // For like button

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupUI()
        configureData()
        
        tableView.reloadData()
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Configure Top Image View
        topImageView.translatesAutoresizingMaskIntoConstraints = false
        topImageView.contentMode = .scaleAspectFill
        topImageView.layer.cornerRadius = 12
        topImageView.clipsToBounds = true
        view.addSubview(topImageView)

        // Configure Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)

        // Configure Description Label
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        view.addSubview(descriptionLabel)

        // Configure Like Button
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        likeButton.tintColor = .red
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        view.addSubview(likeButton)

        // Configure Nutrition Facts
        nutritionLabel.translatesAutoresizingMaskIntoConstraints = false
        nutritionLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nutritionLabel.textColor = .blue
        nutritionLabel.textAlignment = .center
        nutritionLabel.numberOfLines = 0
//        nutritionLabel.text = "Nutrition Facts: High in Protein, Vitamins & Minerals"
        view.addSubview(nutritionLabel)

        // Configure Table View
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SectionItemTableViewCell.self, forCellReuseIdentifier: "SectionItemCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 70
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // Spacing between cells
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)

        // Auto Layout Constraints
        NSLayoutConstraint.activate([
            // Top Image View
            topImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            topImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topImageView.heightAnchor.constraint(equalToConstant: 250),

            // Like Button
            likeButton.topAnchor.constraint(equalTo: topImageView.topAnchor, constant: 10),
            likeButton.trailingAnchor.constraint(equalTo: topImageView.trailingAnchor, constant: -10),
            likeButton.widthAnchor.constraint(equalToConstant: 40),
            likeButton.heightAnchor.constraint(equalToConstant: 40),

            // Title Label
            titleLabel.topAnchor.constraint(equalTo: topImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Description Label
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Nutrition Facts Label
            nutritionLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            nutritionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nutritionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Table View
            tableView.topAnchor.constraint(equalTo: nutritionLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Data Configuration
    private func configureData() {
        if let image = UIImage(named: selectedItem.image) {
            topImageView.image = image
        } else {
            print("Image not found: \(selectedItem.image)")
        }
        titleLabel.text = selectedItem.name
        descriptionLabel.text = selectedItem.description
    }

    // MARK: - Like Button Action
    @objc private func likeButtonTapped() {
        isLiked.toggle()
        let heartImage = isLiked ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: heartImage), for: .normal)

        // Animate button tap
        UIView.animate(withDuration: 0.2, animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.likeButton.transform = CGAffineTransform.identity
            }
        }
    }

    // MARK: - Table View DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SectionItemCell", for: indexPath) as? SectionItemTableViewCell else {
            return UITableViewCell()
        }
        let item = sectionItems[indexPath.row]
        cell.configure(with: item)
        
        // Set the delegate
        cell.delegate = self

        return cell
    }
    private func showAlert(for itemName: String) {
        let alert = UIAlertController(title: "Success", message: "\"\(itemName)\" has been added to MyBowl!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - SectionItemTableViewCellDelegate

extension MealDetailViewController: SectionItemTableViewCellDelegate {
    func didTapAddButton(for item: FeedingMeal) {
        print("Adding item: \(item.name)") // Debugging print statement
        guard let category = BiteSampleData.shared.categories.first(where: { $0.value.contains(where: { $0.name == item.name }) })?.key else {
            print("Category not found for item: \(item.name)")
            return
        }
        
        if let todBiteVC = self.navigationController?.viewControllers.first(where: { $0 is TodBiteViewController }) as? TodBiteViewController {
            if todBiteVC.myBowlItemsDict[category] == nil {
                todBiteVC.myBowlItemsDict[category] = []
            }
            todBiteVC.myBowlItemsDict[category]?.append(item)
            todBiteVC.MealItemDetails(message: "\"\(item.name)\" added to MyBowl!")
            
//            // Show pop-up alert
            showAlert(for: item.name)
            
            // Debug reload logic
            print("MyBowl updated: \(todBiteVC.myBowlItemsDict)")
            
            if todBiteVC.segmentedControl.selectedSegmentIndex == 1 {
                todBiteVC.tableView.reloadData()
            }
        }
    }
}
