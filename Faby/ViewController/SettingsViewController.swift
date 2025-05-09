import UIKit

class SettingsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var collectionView: UICollectionView!
    var tableView: UITableView!
    var searchBar: UISearchBar!
    
    let tableSections = ["PARENT PROFILE", "VACCITIME", "GROWTRACK", "TODBITE", "TODDLER TALK", "HELP & SUPPORT", "CONTACT INFORMATION", "LEGAL"]
    var filteredTableItems: [[String]] = [
        ["Parents Info"],
        ["Vaccine History", "Administered Vaccines"],
        ["Milestone track"],
        ["Today's meal", "Your plan"],
        ["Saved Post"],
        ["Contact support", "FAQs", "Submit feedback"],
        ["Email: support@faby.com", "Phone: +1 (800) 123-4567", "Available 24/7"],
        ["Terms of Service", "Privacy Policy", "Community Guidelines"]
    ]
    let tableItems = [
        ["Parents Info"],
        ["Vaccine History", "Administered Vaccines"],
        ["Milestone track"],
        ["Today's meal", "Your plan"],
        ["Saved Post"],
        ["Contact support", "FAQs", "Submit feedback"],
        ["Email: support@faby.com", "Phone: +1 (800) 123-4567", "Available 24/7"],
        ["Terms of Service", "Privacy Policy", "Community Guidelines"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        view.backgroundColor = .systemGray6
        setupSearchBar()
        setupCollectionView()
        setupTableView()
        setupLayout()
    }
    
    func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.placeholder = "Search Settings"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .systemGray6
        searchBar.tintColor = .black
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredTableItems = tableItems
        } else {
            filteredTableItems = tableItems.map { section in
                section.filter { item in
                    item.lowercased().contains(searchText.lowercased())
                }
            }
        }
        tableView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            // Update cell constraints if needed
            if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows {
                for indexPath in indexPathsForVisibleRows {
                    if let cell = tableView.cellForRow(at: indexPath) as? TableViewCellWithArrow {
                        cell.updateConstraintsIfNeeded()
                    }
                }
            }
        }
    }
    
    // MARK: - Collection View Setup
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width - 20, height: 120)
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.layer.cornerRadius = 12
        collectionView.layer.masksToBounds = true
        collectionView.backgroundColor = .systemGray6
        collectionView.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: "ProfileCell")
        collectionView.isScrollEnabled = false // Disable scrolling in collection view as it's part of the table header
    }
    
    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TableViewCellWithArrow.self, forCellReuseIdentifier: "ArrowCell")
        tableView.backgroundColor = .systemGray6
        view.addSubview(tableView)
    }
    
    // MARK: - Layout Setup
    func setupLayout() {
        // Set up table view to take the full screen
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Create a header view containing the search bar and collection view
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 180))
        headerView.backgroundColor = .systemGray6
        
        // Add search bar to header view
        searchBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        headerView.addSubview(searchBar)
        
        // Add collection view to header view
        collectionView.frame = CGRect(x: 10, y: 60, width: view.frame.width - 20, height: 120)
        headerView.addSubview(collectionView)
        
        // Set the header view as the table's header view
        tableView.tableHeaderView = headerView
    }
    
    // MARK: - Collection View DataSource and Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath) as! ProfileCollectionViewCell
        cell.configure(image: UIImage(named: "profile_picture"), name: "Deepak Prajapati", details: ["03 Dec", "Boy", "70 cm", "12.0 kg"])
        return cell
    }
    
    // MARK: - Table View DataSource and Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTableItems[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArrowCell", for: indexPath) as! TableViewCellWithArrow
        let title = filteredTableItems[indexPath.section][indexPath.row]
        
        // Set appropriate icon based on the section and row
        switch (indexPath.section, indexPath.row) {
        // PARENT PROFILE section
        case (0, 0): // Parents Info
            cell.setLeftIcon(systemName: "person.2.fill")
            
        // VACCITIME section
        case (1, 0): // Vaccine History
            cell.setLeftIcon(systemName: "list.bullet.clipboard")
        case (1, 1): // Administered Vaccines
            cell.setLeftIcon(systemName: "syringe")
            
        // GROWTRACK section
        case (2, 0): // Milestone track
            cell.setLeftIcon(systemName: "chart.line.uptrend.xyaxis")
            
        // TODBITE section
        case (3, 0): // Today's meal
            cell.setLeftIcon(systemName: "fork.knife")
        case (3, 1): // Your plan
            cell.setLeftIcon(systemName: "calendar")
            
        // TODDLER TALK section
        case (4, 0): // Saved Post
            cell.setLeftIcon(systemName: "bookmark.fill")
            
        // HELP & SUPPORT section
        case (5, 0): // Contact support
            cell.setLeftIcon(systemName: "headphones")
        case (5, 1): // FAQs
            cell.setLeftIcon(systemName: "questionmark.circle")
        case (5, 2): // Submit feedback
            cell.setLeftIcon(systemName: "square.and.pencil")
            
        // CONTACT INFORMATION section
        case (6, 0): // Email
            cell.setLeftIcon(systemName: "envelope")
            cell.configure(with: title, showArrow: false)
            return cell
        case (6, 1): // Phone
            cell.setLeftIcon(systemName: "phone")
            cell.configure(with: title, showArrow: false)
            return cell
        case (6, 2): // Available 24/7
            cell.setLeftIcon(systemName: "clock")
            cell.configure(with: title, showArrow: false)
            return cell
            
        // LEGAL section
        case (7, 0): // Terms of Service
            cell.setLeftIcon(systemName: "doc.text")
            cell.configure(with: title, showArrow: false)
            return cell
        case (7, 1): // Privacy Policy
            cell.setLeftIcon(systemName: "lock.shield")
            cell.configure(with: title, showArrow: false)
            return cell
        case (7, 2): // Community Guidelines
            cell.setLeftIcon(systemName: "person.3")
            cell.configure(with: title, showArrow: false)
            return cell
            
        default:
            break
        }
        
        cell.configure(with: title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Standard header for all sections
        let headerView = UIView()
        headerView.backgroundColor = .systemGray6
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .gray
        titleLabel.text = tableSections[section].uppercased()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedSection = tableSections[indexPath.section]
        let selectedItem = filteredTableItems[indexPath.section][indexPath.row]
        
        // Don't navigate for Legal section items
        if selectedSection == "LEGAL" {
            return
        }
        
        // Don't navigate for Contact Information section items
        if selectedSection == "CONTACT INFORMATION" {
            return
        }
        
        switch (selectedSection, selectedItem) {
        case ("PARENT PROFILE", "Parents Info"):
            print("Navigate to Parents Info")
            
        case ("VACCITIME", "Vaccine History"):
            let savedVaccineVC = SavedVaccineViewController()
            navigationController?.pushViewController(savedVaccineVC, animated: true)
            
        case ("VACCITIME", "Administered Vaccines"):
            let newlyScheduledVC = NewlyScheduledVaccineViewController()
            navigationController?.pushViewController(newlyScheduledVC, animated: true)
            
        case ("GROWTRACK", "Milestone track"):
            let milestoneOverviewVC = MilestonesOverviewViewController()
            navigationController?.pushViewController(milestoneOverviewVC, animated: true)
            
        case ("TODBITE", "Today's meal"):
            print("Navigate to Today's meal")
            
        case ("TODBITE", "Your plan"):
            print("Navigate to Your plan")
            
        case ("TODDLER TALK", "Saved Post"):
            let savedPostsVC = SavedPostsViewController()
            navigationController?.pushViewController(savedPostsVC, animated: true)
            
        case ("HELP & SUPPORT", "Contact support"):
            let contactSupportVC = ContactSupportViewController()
            navigationController?.pushViewController(contactSupportVC, animated: true)
            
        case ("HELP & SUPPORT", "FAQs"):
            let faqsVC = FAQsViewController()
            navigationController?.pushViewController(faqsVC, animated: true)
            
        case ("HELP & SUPPORT", "Submit feedback"):
            let submitFeedbackVC = SubmitFeedbackViewController()
            navigationController?.pushViewController(submitFeedbackVC, animated: true)
            
        default:
            break
        }
    }
}

// MARK: - Profile Collection View Cell
class ProfileCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    let nameLabel = UILabel()
    let detailGrid = UIStackView()
    let detail1 = UILabel()
    let detail2 = UILabel()
    let detail3 = UILabel()
    let detail4 = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.layer.cornerRadius = 45
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [detail1, detail2, detail3, detail4].forEach { label in
            label.font = UIFont.systemFont(ofSize: 15)
            label.textColor = .black
            label.textAlignment = .left
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        
        detailGrid.axis = .vertical
        detailGrid.spacing = 5
        detailGrid.alignment = .fill
        detailGrid.distribution = .fillEqually
        detailGrid.translatesAutoresizingMaskIntoConstraints = false
        
        let row1 = UIStackView(arrangedSubviews: [detail1, detail2])
        row1.axis = .horizontal
        row1.spacing = 10
        row1.distribution = .fillEqually
        
        let row2 = UIStackView(arrangedSubviews: [detail3, detail4])
        row2.axis = .horizontal
        row2.spacing = 10
        row2.distribution = .fillEqually
        
        detailGrid.addArrangedSubview(row1)
        detailGrid.addArrangedSubview(row2)
        
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(detailGrid)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 90),
            imageView.heightAnchor.constraint(equalToConstant: 90),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 25),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            detailGrid.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            detailGrid.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 25),
            detailGrid.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            detailGrid.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .white
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(image: UIImage?, name: String, details: [String]) {
        imageView.image = image
        nameLabel.text = name
        detail1.text = details.count > 0 ? details[0] : ""
        detail2.text = details.count > 1 ? details[1] : ""
        detail3.text = details.count > 2 ? details[2] : ""
        detail4.text = details.count > 3 ? details[3] : ""
    }
}

// MARK: - Table View Cell with Arrow
class TableViewCellWithArrow: UITableViewCell {
    let titleLabel = UILabel()
    let arrowImageView = UIImageView()
    let leftIconImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Left icon for items
        leftIconImageView.contentMode = .scaleAspectFit
        leftIconImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(leftIconImageView)
        
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .systemGray3
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            leftIconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            leftIconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            leftIconImageView.widthAnchor.constraint(equalToConstant: 24),
            leftIconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: leftIconImageView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8),
            
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String, showArrow: Bool = true) {
        titleLabel.text = title
        arrowImageView.isHidden = !showArrow
    }
    
    func setLeftIcon(systemName: String) {
        leftIconImageView.image = UIImage(systemName: systemName)
        leftIconImageView.isHidden = false
        leftIconImageView.tintColor = getIconColor(for: systemName)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        leftIconImageView.image = nil
        arrowImageView.isHidden = false
    }
    
    // Helper method to get appropriate color for each icon - all set to gray for consistency
    private func getIconColor(for iconName: String) -> UIColor {
        return UIColor.systemGray
    }
}

// ... (rest of the code remains the same)
