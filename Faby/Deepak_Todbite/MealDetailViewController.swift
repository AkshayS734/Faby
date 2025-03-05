import UIKit

class MealDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - UI Components
    private let topImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let likeButton = UIButton()
    private let nutritionLabel = UILabel()
    private let tableView = UITableView()

    // MARK: - Data
    var selectedItem: FeedingMeal!
    var sectionItems: [FeedingMeal] = []
    private var isLiked = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupUI()
        configureData()
        setupRightBarButton()
        tableView.reloadData()
    }

    // MARK: - UI Setup
    private func setupUI() {
        topImageView.contentMode = .scaleAspectFill
        topImageView.layer.cornerRadius = 12
        topImageView.clipsToBounds = true

        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .darkGray

        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        likeButton.tintColor = .red
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)

       

        tableView.register(SectionItemTableViewCell.self, forCellReuseIdentifier: "SectionItemCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 70

        [topImageView, titleLabel, descriptionLabel, likeButton, nutritionLabel, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            topImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            topImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topImageView.heightAnchor.constraint(equalToConstant: 300),

            likeButton.topAnchor.constraint(equalTo: topImageView.topAnchor, constant: 10),
            likeButton.trailingAnchor.constraint(equalTo: topImageView.trailingAnchor, constant: -10),

            titleLabel.topAnchor.constraint(equalTo: topImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            nutritionLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            nutritionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: nutritionLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    

    // MARK: - Data Setup
    private func configureData() {
        topImageView.image = UIImage(named: selectedItem.image)
        titleLabel.text = selectedItem.name
        descriptionLabel.text = selectedItem.description
    }

    // MARK: - Like Button
    @objc private func likeButtonTapped() {
        isLiked.toggle()

        let heartImage = isLiked ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: heartImage), for: .normal)

        updateFavoriteStatus()

        UIView.animate(withDuration: 0.2, animations: {
            self.likeButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.likeButton.transform = .identity
            }
        }
    }

    private func updateFavoriteStatus() {
        var favorites = UserDefaults.standard.array(forKey: "favoriteMeals") as? [[String: String]] ?? []

        if isLiked {
            // Add to favorites if not already present
            let mealDict: [String: String] = [
                "name": selectedItem.name,
                "image": selectedItem.image,
                "description": selectedItem.description
            ]
            if !favorites.contains(where: { $0["name"] == selectedItem.name }) {
                favorites.append(mealDict)
            }
        } else {
           
            favorites.removeAll(where: { $0["name"] == selectedItem.name })
        }

        UserDefaults.standard.set(favorites, forKey: "favoriteMeals")
    }


    // MARK: - Right Bar Button (More Actions)
    private func setupRightBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            style: .plain,
            target: self,
            action: #selector(showMoreOptions)
        )
    }

    @objc private func showMoreOptions() {
        let sheet = UIAlertController(title: "More Options", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Share Meal", style: .default, handler: shareMeal))
        sheet.addAction(UIAlertAction(title: "View Nutrition Facts", style: .default, handler: showNutritionFacts))
        sheet.addAction(UIAlertAction(title: "Add to Calendar", style: .default, handler: addToCalendar))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    private func shareMeal(_ action: UIAlertAction) {
        let shareText = "Check out this meal: \(selectedItem.name)\n\n\(selectedItem.description)"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(activityVC, animated: true)
    }

    private func showNutritionFacts(_ action: UIAlertAction) {
        let alert = UIAlertController(title: "Nutrition Facts", message: "High Protein\nVitamins: A, B12, C\nMinerals: Iron, Calcium", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func addToCalendar(_ action: UIAlertAction) {
        let alert = UIAlertController(title: "Added!", message: "\(selectedItem.name) added to Calendar.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sectionItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SectionItemCell", for: indexPath) as! SectionItemTableViewCell
        cell.configure(with: sectionItems[indexPath.row])
        cell.delegate = self
        return cell
    }
}

// MARK: - Add to MyBowl Logic (Same as Existing)
extension MealDetailViewController: SectionItemTableViewCellDelegate {
    func didTapAddButton(for item: FeedingMeal) {
        guard let category = BiteSampleData.shared.categories.first(where: { $0.value.contains { $0.name == item.name } })?.key else {
            print("❌ Category not found for \(item.name)")
            return
        }

        if let todBiteVC = navigationController?.viewControllers.first(where: { $0 is TodBiteViewController }) as? TodBiteViewController {

            if let existingMeals = todBiteVC.myBowlItemsDict[category], existingMeals.contains(where: { $0.name == item.name }) {
                //  Already Added - Show Message
                todBiteVC.MealItemDetails(message: "❗ \"\(item.name)\" is already added to MyBowl.")
            } else {
                //  Add New Meal
                if todBiteVC.myBowlItemsDict[category] == nil {
                    todBiteVC.myBowlItemsDict[category] = []
                }
                todBiteVC.myBowlItemsDict[category]?.append(item)

                //  Show success message
                todBiteVC.MealItemDetails(message: "✅ \"\(item.name)\" added to MyBowl!")

                //  Reload table if needed
                if todBiteVC.segmentedControl.selectedSegmentIndex == 1 {
                    todBiteVC.tableView.reloadData()
                }
            }
        }
    }
}
