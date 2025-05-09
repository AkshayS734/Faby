import UIKit

class ModernDropdownViewController: UIViewController {
    // MARK: - Properties
    private let options: [String]
    private var selectedIndex: Int
    private let tableView = UITableView()
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    
    // Callback for selection
    var onSelection: ((Int) -> Void)?
    
    // MARK: - Initialization
    init(options: [String], selectedIndex: Int) {
        self.options = options
        self.selectedIndex = selectedIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Setup blur effect view
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 14
        blurView.layer.masksToBounds = true
        view.addSubview(blurView)
        
        // Setup table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.bounces = true
        tableView.register(ModernDropdownCell.self, forCellReuseIdentifier: "DropdownCell")
        tableView.layer.cornerRadius = 14
        tableView.layer.masksToBounds = true
        blurView.contentView.addSubview(tableView)
        
        // Add subtle shadow to the blur view
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.1
        
        // Setup constraints
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor)
        ])
        
        // Scroll to selected index
        if selectedIndex >= 0 && selectedIndex < options.count {
            tableView.scrollToRow(at: IndexPath(row: selectedIndex, section: 0), at: .middle, animated: false)
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ModernDropdownViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownCell", for: indexPath) as! ModernDropdownCell
        
        // Configure cell
        cell.configure(with: options[indexPath.row], isSelected: indexPath.row == selectedIndex)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Update selected index
        selectedIndex = indexPath.row
        tableView.reloadData()
        
        // Call selection handler
        onSelection?(indexPath.row)
        
        // Dismiss after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}

// MARK: - ModernDropdownCell
class ModernDropdownCell: UITableViewCell {
    // MARK: - Properties
    private let titleLabel = UILabel()
    private let checkmarkImageView = UIImageView()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Setup cell appearance
        backgroundColor = .clear
        selectionStyle = .none
        
        // Setup title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        titleLabel.textColor = .label
        contentView.addSubview(titleLabel)
        
        // Setup checkmark image view
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.tintColor = .systemBlue
        if let checkmarkImage = UIImage(systemName: "checkmark") {
            checkmarkImageView.image = checkmarkImage
        }
        checkmarkImageView.isHidden = true
        contentView.addSubview(checkmarkImageView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor, constant: -8),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 20),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    // MARK: - Configuration
    func configure(with title: String, isSelected: Bool) {
        titleLabel.text = title
        checkmarkImageView.isHidden = !isSelected
        
        // Apply selected styling if needed
        if isSelected {
            titleLabel.textColor = .systemBlue
            titleLabel.font = UIFont.preferredFont(forTextStyle: .body).withTraits(.traitBold)
        } else {
            titleLabel.textColor = .label
            titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        }
    }
    
    // MARK: - Selection Animation
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            UIView.animate(withDuration: 0.1, animations: {
                self.contentView.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.5)
            })
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            UIView.animate(withDuration: 0.1, animations: {
                self.contentView.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.5)
            })
        } else if !isSelected {
            UIView.animate(withDuration: 0.1, animations: {
                self.contentView.backgroundColor = .clear
            })
        }
    }
}

// Note: UIFont extension with withTraits method is already defined in ModernSignupViewController.swift
