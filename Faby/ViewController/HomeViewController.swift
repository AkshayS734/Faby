import UIKit

class HomeViewController: UIViewController {

    
    struct Vaccination {
        let title: String
        let date: String
        let location: String
        var isChecked: Bool
    }
    
    var vaccinationsData: [Vaccination] = []  // Holds vaccination data

    // MARK: - UI Components
    var baby = BabyDataModel.shared.babyList[0]
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Date"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let specialMomentsLabel: UILabel = {
        let label = UILabel()
        label.text = "Special Moments"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let specialMomentsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 200, height: 150)
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private let todaysBitesLabel: UILabel = {
        let label = UILabel()
        label.text = "Today's Bites"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let todaysBitesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 250, height: 150)
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private let upcomingVaccinationLabel: UILabel = {
        let label = UILabel()
        label.text = "Upcoming Vaccination"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let vaccinationsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Data
    var specialMomentsData: [String] = [] // Add actual data source for special moments
    var todaysBitesData: [String] = [] // Add actual data source for today's bites

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        setupDelegates()
        loadVaccinationData()
        updateNameLabel()
        updateDateLabel()
    }
    private func updateNameLabel() {
        nameLabel.text = baby.name
    }

    private func updateDateLabel() {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        dateLabel.text = formatter.string(from: Date())
    }
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(nameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(specialMomentsLabel)
        contentView.addSubview(specialMomentsCollectionView)
        contentView.addSubview(todaysBitesLabel)
        contentView.addSubview(todaysBitesCollectionView)
        contentView.addSubview(upcomingVaccinationLabel)
        contentView.addSubview(vaccinationsStackView)

        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: vaccinationsStackView.bottomAnchor, constant: 20), // Fix this line
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Name Label
            nameLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            // Date Label
            dateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            // Special Moments Label
            specialMomentsLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            specialMomentsLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            // Special Moments Collection View
            specialMomentsCollectionView.topAnchor.constraint(equalTo: specialMomentsLabel.bottomAnchor, constant: 10),
            specialMomentsCollectionView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            specialMomentsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            specialMomentsCollectionView.heightAnchor.constraint(equalToConstant: 150),

            // Today's Bites Label
            todaysBitesLabel.topAnchor.constraint(equalTo: specialMomentsCollectionView.bottomAnchor, constant: 20),
            todaysBitesLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            // Today's Bites Collection View
            todaysBitesCollectionView.topAnchor.constraint(equalTo: todaysBitesLabel.bottomAnchor, constant: 10),
            todaysBitesCollectionView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            todaysBitesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            todaysBitesCollectionView.heightAnchor.constraint(equalToConstant: 150),

            // Upcoming Vaccination Label
            upcomingVaccinationLabel.topAnchor.constraint(equalTo: todaysBitesCollectionView.bottomAnchor, constant: 20),
            upcomingVaccinationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            // Vaccination Stack View
            vaccinationsStackView.topAnchor.constraint(equalTo: upcomingVaccinationLabel.bottomAnchor, constant: 10),
            vaccinationsStackView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            vaccinationsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            vaccinationsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // Update the scroll view's content size after loading content
    private func updateScrollViewContentSize() {
        let totalHeight = nameLabel.frame.height +
                          dateLabel.frame.height +
                          specialMomentsLabel.frame.height +
                          specialMomentsCollectionView.frame.height +
                          todaysBitesLabel.frame.height +
                          todaysBitesCollectionView.frame.height +
                          upcomingVaccinationLabel.frame.height +
                          vaccinationsStackView.frame.height + 20 // Add padding
        scrollView.contentSize = CGSize(width: view.frame.width, height: totalHeight)
    }

    private func setupDelegates() {
        specialMomentsCollectionView.delegate = self
        specialMomentsCollectionView.dataSource = self
        todaysBitesCollectionView.delegate = self
        todaysBitesCollectionView.dataSource = self
    }

    private func loadVaccinationData() {
        // Example: Dynamic data loading (from UserDefaults, network, etc.)
        if let savedData = UserDefaults.standard.array(forKey: "VaccinationSchedules") as? [[String: String]] {
            vaccinationsData = savedData.compactMap { vaccination in
                guard let title = vaccination["hospital"], let date = vaccination["date"], let location = vaccination["address"] else { return nil }
                return Vaccination(title: title, date: date, location: location, isChecked: false)
            }
            updateVaccinationUI()
        }
    }
    
    private func updateVaccinationUI() {
        // Remove all existing cards first
        for subview in vaccinationsStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }

        // Add new vaccination cards based on the updated data
        for vaccination in vaccinationsData {
            addVaccinationCard(vaccination: vaccination)
        }
    }

    private func addVaccinationCard(vaccination: Vaccination) {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 10
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.1
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = vaccination.title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)

        let dateLabel = UILabel()
        dateLabel.text = vaccination.date
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .gray

        let locationLabel = UILabel()
        locationLabel.text = vaccination.location
        locationLabel.font = UIFont.systemFont(ofSize: 14)
        locationLabel.textColor = .gray

        let checkmarkButton = UIButton(type: .custom)
        checkmarkButton.setImage(UIImage(systemName: "circle"), for: .normal)
        checkmarkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        checkmarkButton.tintColor = UIColor(hex: "#0076BA") // Custom color
        checkmarkButton.isSelected = vaccination.isChecked
        checkmarkButton.addTarget(self, action: #selector(didToggleCheckmark(_:)), for: .touchUpInside)
        checkmarkButton.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [titleLabel, dateLabel, locationLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stackView)
        card.addSubview(checkmarkButton)

        vaccinationsStackView.addArrangedSubview(card)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 80),
            stackView.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: checkmarkButton.leadingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10),
            checkmarkButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
            checkmarkButton.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            checkmarkButton.widthAnchor.constraint(equalToConstant: 30),
            checkmarkButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    @objc private func didToggleCheckmark(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        if let index = vaccinationsStackView.arrangedSubviews.firstIndex(of: sender.superview!) {
            vaccinationsData[index].isChecked = sender.isSelected
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == specialMomentsCollectionView {
            return specialMomentsData.count
        } else {
            return todaysBitesData.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == specialMomentsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpecialMomentCell", for: indexPath)
            // Configure special moment cell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodaysBiteCell", for: indexPath)
            // Configure today's bite cell
            return cell
        }
    }
}
