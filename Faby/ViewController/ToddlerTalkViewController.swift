import UIKit

class ToddlerTalkViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var filteredData: [Card] = [] // Array of cards that will be filtered

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up table view
        tableView.dataSource = self
        tableView.delegate = self
        
        // Set initial filtered data to all data
        filteredData = CardDataProvider.shared.cardData
        
        // Set row height
        tableView.rowHeight = 140
        
        // Set up search bar
        searchBar.delegate = self
        searchBar.placeholder = "Search topics..."
        
        // Register the custom cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CardCell")
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count / 2 + filteredData.count % 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath)
        
        // Create a row of two buttons
        let rowStackView = UIStackView()
        rowStackView.axis = .horizontal
        rowStackView.spacing = 16
        rowStackView.distribution = .fillEqually
        rowStackView.alignment = .fill
        
        // First card data (title and subtitle)
        let firstIndex = indexPath.row * 2
        let firstCard = filteredData[firstIndex]
        let firstButton = createCardButton(title: firstCard.title, subtitle: firstCard.subtitle)
        rowStackView.addArrangedSubview(firstButton)
        
        // Second card data (title and subtitle) - if available
        if firstIndex + 1 < filteredData.count {
            let secondCard = filteredData[firstIndex + 1]
            let secondButton = createCardButton(title: secondCard.title, subtitle: secondCard.subtitle)
            rowStackView.addArrangedSubview(secondButton)
        }
        
        // Add rowStackView to the cell's content view
        cell.contentView.subviews.forEach { $0.removeFromSuperview() } // Clear previous content
        cell.contentView.addSubview(rowStackView)

        // Set constraints for rowStackView
        rowStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rowStackView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            rowStackView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            rowStackView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            rowStackView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8)
        ])
        
        // Set card background color to white
        cell.contentView.backgroundColor = .white
        cell.contentView.layer.cornerRadius = 8
        cell.contentView.layer.masksToBounds = false
        
        // Set shadow for the entire cell (background)
        cell.contentView.layer.shadowColor = UIColor.white.cgColor
        cell.contentView.layer.shadowOpacity = 0.1
        cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.contentView.layer.shadowRadius = 4
        
        cell.selectionStyle = .none
        
        return cell
    }

    // MARK: Helper Methods

    func createCardButton(title: String, subtitle: String) -> UIButton {
        let button = UIButton(type: .system)
        
        // Set background color and styling
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        
        // Set the title and subtitle
        let titleString = "\(title)\n\(subtitle)"
        button.setTitle(titleString, for: .normal)
        
        // Set fonts for title and subtitle
        let titleFont = UIFont.boldSystemFont(ofSize: 18)
        let subtitleFont = UIFont.systemFont(ofSize: 14)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.black
        ]
        
        let attributedTitle = NSMutableAttributedString(string: title, attributes: attributes)
        
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: subtitleFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        let attributedSubtitle = NSAttributedString(string: "\n\(subtitle)", attributes: subtitleAttributes)
        
        attributedTitle.append(attributedSubtitle)
        
        // Set the formatted text
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        // Align text to the left
        button.titleLabel?.numberOfLines = 0
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        return button
    }

    // MARK: UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredData = CardDataProvider.shared.cardData // If search is empty, show all data
        } else {
            filteredData = CardDataProvider.shared.cardData.filter { card in
                return card.title.lowercased().contains(searchText.lowercased()) || card.subtitle.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Reload table view with filtered data
        tableView.reloadData()
    }
}
