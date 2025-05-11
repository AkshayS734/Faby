import UIKit

class TodaysBitesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // The meals data passed from HomeViewController
    var meals: [TodayBite] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGroupedBackground
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Today's Bites"
        view.backgroundColor = .systemGroupedBackground
        
        setupTableView()
    }
    
    private func setupTableView() {
        // Register cell type
        tableView.register(TodaysBiteTableViewCell.self, forCellReuseIdentifier: "TodaysBiteCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodaysBiteCell", for: indexPath) as! TodaysBiteTableViewCell
        
        let meal = meals[indexPath.row]
        cell.configure(with: meal)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected meal
        let selectedMeal = meals[indexPath.row]
        
        // If we have access to the TodBiteViewController tab, we could navigate to it
        // and show details for the selected meal, but for now we'll just deselect the row
        
        // Add navigation to meal detail page if needed:
        // let detailVC = MealDetailViewController()
        // detailVC.configure(with: selectedMeal)
        // navigationController?.pushViewController(detailVC, animated: true)
        
        // Deselect the row with animation
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Table View Cell
class TodaysBiteTableViewCell: UITableViewCell {
    
    private let mealImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(mealImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            mealImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            mealImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            mealImageView.widthAnchor.constraint(equalToConstant: 70),
            mealImageView.heightAnchor.constraint(equalToConstant: 70),
            
            titleLabel.leadingAnchor.constraint(equalTo: mealImageView.trailingAnchor, constant: 15),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            timeLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
    
    func configure(with meal: TodayBite) {
        titleLabel.text = meal.title
        timeLabel.text = meal.time
        
        // Set a placeholder image initially
        mealImageView.image = UIImage(named: "placeholder") ?? UIImage(systemName: "photo")
        
        let imageName = meal.imageName
        
        // Handle different image source types
        if let image = UIImage(named: imageName) {
            // Local asset case
            mealImageView.image = image
        } else if imageName.hasPrefix("http://") || imageName.hasPrefix("https://") {
            // URL case - load asynchronously
            loadImageFromURL(imageUrl: imageName)
        } else if imageName.contains("/") {
            // Local file path case
            if let image = UIImage(contentsOfFile: imageName) {
                mealImageView.image = image
            }
        }
    }
    
    private func loadImageFromURL(imageUrl: String) {
        guard let url = URL(string: imageUrl) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  error == nil,
                  let data = data,
                  let image = UIImage(data: data) else {
                return
            }
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.mealImageView.image = image
            }
        }
        
        task.resume()
    }
} 