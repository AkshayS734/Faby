import UIKit

class SettingsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var collectionView: UICollectionView!
    var tableView: UITableView!
    var searchBar: UISearchBar!
    
    let tableSections = ["PARENT PROFILE", "VACCITIME", "GROWTRACK", "TODBITE", "HELP & SUPPORT"]
    var filteredTableItems: [[String]] = [
        ["Parents Info"],
        ["Administered Vaccines"],
        ["Milestone track"],
        ["Today's meal", "Your plan"],
        ["Contact support", "FAQs", "Submit feedback"]
    ]
    let tableItems = [
        ["Parents Info"],
        ["Administered Vaccines"],
        ["Milestone track"],
        ["Today's meal", "Your plan"],
        ["Contact support", "FAQs", "Submit feedback"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        view.backgroundColor = .systemGroupedBackground
        setupSearchBar()
        setupCollectionView()
        setupTableView()
        setupLayout()
    }
    
    func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.placeholder = "Search Settings"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .systemGroupedBackground
        searchBar.tintColor = .black
        view.addSubview(searchBar)
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
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: "ProfileCell")
        view.addSubview(collectionView)
    }
    
    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TableViewCellWithArrow.self, forCellReuseIdentifier: "ArrowCell")
        tableView.backgroundColor = .systemGroupedBackground
        view.addSubview(tableView)
    }
    
    // MARK: - Layout Setup
    func setupLayout() {
        NSLayoutConstraint.activate([
            // Search Bar Constraints
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Collection View Constraints
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: 120),
            
            // Table View Constraints
            tableView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
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
        cell.configure(with: title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemGroupedBackground
        
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle navigation based on selected item
        let selectedSection = tableSections[indexPath.section]
        let selectedItem = filteredTableItems[indexPath.section][indexPath.row]
        
        switch (selectedSection, selectedItem) {
        case ("VACCITIME", "Administered Vaccines"):
            let savedVaccineVC = SavedVaccineViewController()
            navigationController?.pushViewController(savedVaccineVC, animated: true)
            
        case ("GROWTRACK", "Milestone track"):
            let milestoneOverviewVC = MilestonesOverviewViewController()
            navigationController?.pushViewController(milestoneOverviewVC, animated: true)
            
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .gray
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowImageView)
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with text: String) {
        titleLabel.text = text
    }
}
