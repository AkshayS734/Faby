import UIKit

struct Vaccination {
    let title: String
    let date: String
    let location: String
    var isChecked: Bool
}

class HomeViewController: UIViewController {
    
    var vaccinationsData: [Vaccination] = []
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
    private let specialMomentsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    
    var todaysBitesData: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSpecialMoments), name: .milestonesAchievedUpdated, object: nil)
        setupUI()
        setupDelegates()
        loadVaccinationData()
        updateNameLabel()
        updateDateLabel()
        embedSpecialMomentsViewController()
    }
    
    @objc func updateSpecialMoments() {
        embedSpecialMomentsViewController()
    }
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(nameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(specialMomentsLabel)
        contentView.addSubview(specialMomentsContainerView)
        contentView.addSubview(todaysBitesLabel)
        contentView.addSubview(todaysBitesCollectionView)
        contentView.addSubview(upcomingVaccinationLabel)
        contentView.addSubview(vaccinationsStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: vaccinationsStackView.bottomAnchor, constant: 20),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            nameLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            dateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            specialMomentsLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            specialMomentsLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            specialMomentsContainerView.topAnchor.constraint(equalTo: specialMomentsLabel.bottomAnchor, constant: 10),
            specialMomentsContainerView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            specialMomentsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            specialMomentsContainerView.heightAnchor.constraint(equalToConstant: 225),

            todaysBitesLabel.topAnchor.constraint(equalTo: specialMomentsContainerView.bottomAnchor, constant: 20),
            todaysBitesLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            todaysBitesCollectionView.topAnchor.constraint(equalTo: todaysBitesLabel.bottomAnchor, constant: 10),
            todaysBitesCollectionView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            todaysBitesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            todaysBitesCollectionView.heightAnchor.constraint(equalToConstant: 150),

            upcomingVaccinationLabel.topAnchor.constraint(equalTo: todaysBitesCollectionView.bottomAnchor, constant: 20),
            upcomingVaccinationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            vaccinationsStackView.topAnchor.constraint(equalTo: upcomingVaccinationLabel.bottomAnchor, constant: 10),
            vaccinationsStackView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            vaccinationsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            vaccinationsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupDelegates() {
        todaysBitesCollectionView.delegate = self
        todaysBitesCollectionView.dataSource = self
    }
    
    private func updateNameLabel() {
        nameLabel.text = baby.name
    }
    
    private func updateDateLabel() {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        dateLabel.text = formatter.string(from: Date())
    }
    
    private func loadVaccinationData() {
        if let savedData = UserDefaults.standard.array(forKey: "VaccinationSchedules") as? [[String: String]] {
            vaccinationsData = savedData.compactMap { vaccination in
                guard let title = vaccination["hospital"], let date = vaccination["date"], let location = vaccination["address"] else { return nil }
                return Vaccination(title: title, date: date, location: location, isChecked: false)
            }
            updateVaccinationUI()
        }
    }
    
    private func updateVaccinationUI() {
        vaccinationsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
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

        let stackView = UIStackView(arrangedSubviews: [titleLabel, dateLabel, locationLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stackView)

        vaccinationsStackView.addArrangedSubview(card)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 80),
            stackView.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10)
        ])
    }
    
    private func embedSpecialMomentsViewController() {
        let specialMomentsVC = SpecialMomentsViewController()
        addChild(specialMomentsVC)
        specialMomentsVC.view.translatesAutoresizingMaskIntoConstraints = false
        specialMomentsContainerView.addSubview(specialMomentsVC.view)
        specialMomentsVC.populateMilestones()
        NSLayoutConstraint.activate([
            specialMomentsVC.view.topAnchor.constraint(equalTo: specialMomentsContainerView.topAnchor),
            specialMomentsVC.view.leadingAnchor.constraint(equalTo: specialMomentsContainerView.leadingAnchor),
            specialMomentsVC.view.trailingAnchor.constraint(equalTo: specialMomentsContainerView.trailingAnchor),
            specialMomentsVC.view.bottomAnchor.constraint(equalTo: specialMomentsContainerView.bottomAnchor)
        ])

        specialMomentsVC.didMove(toParent: self)
        
    }

}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return todaysBitesData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BitesCell", for: indexPath)
        cell.backgroundColor = .systemBlue
        return cell
    }
}
