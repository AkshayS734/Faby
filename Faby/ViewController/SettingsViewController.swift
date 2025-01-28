import UIKit

class SettingsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    var collectionView: UICollectionView!
    var tableView: UITableView!
    
    // Data for table view
    let tableSections = ["Parent Profile", "VacciAlert", "GrowTrack", "Todbite", "Help & Support"]
    let tableItems = [
        ["Parents Info"],
        ["Vaccine record", "View full Schedule"],
        ["View Growth Chart", "Milestone track"],
        ["Today meal 🍴", "Your plan"],
        ["contact support","FAQs","Submit feedback"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        
        setupCollectionView()
        setupTableView()
        setupLayout()
    }
    
    // MARK: - Collection View Setup
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: view.frame.width - 20, height: 150)
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
//        collectionView.backgroundColor = .systemGray6
        collectionView.layer.cornerRadius = 10
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: "ProfileCell")
        view.addSubview(collectionView)
    }
    
    // MARK: - Table View Setup
    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TableViewCellWithArrow.self, forCellReuseIdentifier: "ArrowCell")
        
        view.addSubview(tableView)
    }
    
    // MARK: - Layout Setup
    func setupLayout() {
        NSLayoutConstraint.activate([
            // Collection View Constraints
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.heightAnchor.constraint(equalToConstant: 150),
            
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
        cell.configure(
            image: UIImage(named: "profileImage"),
            name: "Deepak Prajapati",
            details: ["03 Dec", "Boy", "70 cm", "12.0 kg"]
        )
        return cell
    }
    
    // MARK: - Table View DataSource and Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableItems[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArrowCell", for: indexPath) as! TableViewCellWithArrow
        let title = tableItems[indexPath.section][indexPath.row]
        cell.configure(with: title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemGray6

        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20) // Bold and font size 20
        titleLabel.textColor = .black
        titleLabel.text = tableSections[section]
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15)
        ])

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50 // Adjust as needed
    }
}

// MARK: - Custom Collection View Cell
class ProfileCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    let nameLabel = UILabel()
    let detailGrid = UIStackView() // For the 2x2 matrix grid

    let detail1 = UILabel()
    let detail2 = UILabel()
    let detail3 = UILabel()
    let detail4 = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Profile Image
        imageView.layer.cornerRadius = 60
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // Username Label
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        // Grid Labels
        [detail1, detail2, detail3, detail4].forEach { label in
            label.font = UIFont.systemFont(ofSize: 15)
            label.textColor = .black
            label.textAlignment = .left
            label.translatesAutoresizingMaskIntoConstraints = false
        }

        // 2x2 Matrix Grid using a Vertical Stack View
        detailGrid.axis = .vertical
        detailGrid.spacing = 5
        detailGrid.alignment = .fill
        detailGrid.distribution = .fillEqually
        detailGrid.translatesAutoresizingMaskIntoConstraints = false

        let row1 = UIStackView(arrangedSubviews: [detail1, detail2])
        let row2 = UIStackView(arrangedSubviews: [detail3, detail4])
        row1.axis = .horizontal
        row1.spacing = 10
        row1.distribution = .fillEqually
        row2.axis = .horizontal
        row2.spacing = 10
        row2.distribution = .fillEqually

        detailGrid.addArrangedSubview(row1)
        detailGrid.addArrangedSubview(row2)

        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(detailGrid)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 120),
            imageView.heightAnchor.constraint(equalToConstant: 120),

            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
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

// MARK: - Custom Table View Cell
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
