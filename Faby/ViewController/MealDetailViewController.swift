import UIKit

class MealDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - UI Components
    private let topImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let tableView = UITableView()

    // MARK: - Data
    var selectedItem: Item!
    var sectionItems: [Item] = []

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupUI()
        configureData()
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Configure Top Image View
        topImageView.translatesAutoresizingMaskIntoConstraints = false
//        topImageView.contentMode = .scaleToFill
        topImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16)
        topImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: 16)
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

        // Configure Table View
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SectionItemTableViewCell.self, forCellReuseIdentifier: "SectionItemCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.tableFooterView = UIView() // Removes extra separators
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        view.addSubview(tableView)

        // Add Constraints
        NSLayoutConstraint.activate([
            // Top Image View
            topImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topImageView.heightAnchor.constraint(equalToConstant: 250),
            topImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            topImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: 16),

            // Title Label
            titleLabel.topAnchor.constraint(equalTo: topImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Description Label
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Table View
            tableView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Data Configuration
    private func configureData() {
        topImageView.image = UIImage(named: selectedItem.image)
        titleLabel.text = selectedItem.name
        descriptionLabel.text = selectedItem.description
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
    // MARK: - Helper Method
        private func showAlert(for itemName: String) {
            let alert = UIAlertController(title: "Success", message: "\"\(itemName)\" has been added to MyBowl!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - SectionItemTableViewCellDelegate
    extension MealDetailViewController: SectionItemTableViewCellDelegate {
        func didTapAddButton(for item: Item) {
            print("Adding item: \(item.name)") // Debugging print statement
            guard let category = Todbite.shared.categories.first(where: { $0.value.contains(where: { $0.name == item.name }) })?.key else {
                print("Category not found for item: \(item.name)")
                return
            }

            if let todBiteVC = self.navigationController?.viewControllers.first(where: { $0 is TodBiteViewController }) as? TodBiteViewController {
                if todBiteVC.myBowlItemsDict[category] == nil {
                    todBiteVC.myBowlItemsDict[category] = []
                }
                todBiteVC.myBowlItemsDict[category]?.append(item)
                todBiteVC.showToast(message: "\"\(item.name)\" added to MyBowl!")
                
                // Show pop-up alert
                showAlert(for: item.name)
                
                // Debug reload logic
                print("MyBowl updated: \(todBiteVC.myBowlItemsDict)")
                
                if todBiteVC.segmentedControl.selectedSegmentIndex == 1 {
                    todBiteVC.tableView.reloadData()
                }
            }
        }
    }

