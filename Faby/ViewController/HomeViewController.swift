import UIKit

struct Vaccination {
    let title: String
    let date: String
    let location: String
    var isChecked: Bool
}
struct TodayBite {
    let title: String
    let time: String
    let imageName: String
}

class HomeViewController: UIViewController {
    
    var vaccinationsData: [Vaccination] = []
    var baby = BabyDataModel.shared.babyList[0]
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
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
        label.font = UIFont.boldSystemFont(ofSize: 34)
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
        collectionView.backgroundColor = .systemGray6
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    private let todaysBitesEmptyStateContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let todaysBitesEmptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "today_bite")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let todaysBitesEmptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No meal plan added yet"
        label.textColor = UIColor(hex: "#333333")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addMealPlanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Meal Plan", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = UIColor(hex: "#06D6A0")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addMealPlanTapped), for: .touchUpInside)
        return button
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
    
    
    var todaysBitesData: [TodayBite] = [
        TodayBite(title: "Early Bite", time: "7:30 AM - 8:00 AM", imageName: "Mashed Banana with Milk"),
        TodayBite(title: "Nourish Bite", time: "10:00 AM - 10:30 AM", imageName: "Poha with Vegetables"),
        TodayBite(title: "Midday Bite", time: "1:00 PM - 1:30 AM", imageName: "Spinach Dal with Rice"),
        TodayBite(title: "Snack Bite", time: "4:00 PM - 4:30 PM", imageName: "Vegetable Pulao"),
        TodayBite(title: "Night Bite", time: "7:30 PM - 8:00 PM", imageName: "Gobhi Aloo With Roti")
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .plain,
            target: self,
            action: #selector(goToSettings)
        )
        NotificationCenter.default.addObserver(self, selector: #selector(updateSpecialMoments), name: .milestonesAchievedUpdated, object: nil)
        todaysBitesCollectionView.register(UINib(nibName: "TodayBiteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BitesCell")
        
        // Default state for empty states
        todaysBitesEmptyStateContainer.isHidden = true
        
        // Add tap gesture recognizer to the Today's Bites empty state container
        let todaysBitesTapGesture = UITapGestureRecognizer(target: self, action: #selector(openTodBiteViewController))
        todaysBitesEmptyStateContainer.addGestureRecognizer(todaysBitesTapGesture)
        todaysBitesEmptyStateContainer.isUserInteractionEnabled = true
        
        // Add target to the Add Meal Plan button
        addMealPlanButton.addTarget(self, action: #selector(openTodBiteViewController), for: .touchUpInside)
        
        setupUI()
        setupDelegates()
        loadVaccinationData()
        updateNameLabel()
        updateDateLabel()
        embedSpecialMomentsViewController()
    }
    @objc func goToSettings() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
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
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            dateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            specialMomentsLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            specialMomentsLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            specialMomentsContainerView.topAnchor.constraint(equalTo: specialMomentsLabel.bottomAnchor, constant: 10),
            specialMomentsContainerView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            specialMomentsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            specialMomentsContainerView.heightAnchor.constraint(equalToConstant: 220),
            
            todaysBitesLabel.topAnchor.constraint(equalTo: specialMomentsContainerView.bottomAnchor),
            todaysBitesLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            todaysBitesCollectionView.topAnchor.constraint(equalTo: todaysBitesLabel.bottomAnchor, constant: 10),
            todaysBitesCollectionView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            todaysBitesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            todaysBitesCollectionView.heightAnchor.constraint(equalToConstant: 225)
        ])
    }
    
    private func setupVaccineView() {
        vaccineView?.removeFromSuperview()
        
        if let oldVaccineViewController = children.first(where: { $0 is UIHostingController<VaccineCardsView> }) {
            oldVaccineViewController.willMove(toParent: nil)
            oldVaccineViewController.view.removeFromSuperview()
            oldVaccineViewController.removeFromParent()
        }
        
        let vaccineCardsView = UIHostingController(rootView: VaccineCardsView(
            vaccines: scheduledVaccines,
            onVaccineCompleted: { [weak self] vaccine in
                guard let self = self else { return }
                
                if let index = self.scheduledVaccines.firstIndex(where: { $0 == vaccine }) {
                    self.scheduledVaccines.remove(at: index)
                    self.completedVaccinesStorage.append(vaccine)
                    
                    if let scheduleToRemove = self.storageManager.getAllSchedules().first(where: {
                        $0.type == vaccine["type"] &&
                        $0.scheduledDate == vaccine["date"] &&
                        $0.hospitalName == vaccine["hospital"]
                    }) {
                        self.storageManager.deleteSchedule(id: scheduleToRemove.id)
                    }
                    
                    DispatchQueue.main.async {
                        self.loadVaccinations()
                    }
                }
            }
        )
        )
        
        addChild(vaccineCardsView)
        vaccineCardsView.view.translatesAutoresizingMaskIntoConstraints = false
        vaccineCardsView.view.backgroundColor = UIColor(hex: "#f2f2f7")
        
        if let index = contentView.subviews.firstIndex(of: todaysBitesCollectionView) {
            contentView.insertSubview(vaccineCardsView.view, at: index + 1)
        } else {
            contentView.addSubview(vaccineCardsView.view)
        }
        
        vaccineCardsView.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            vaccineCardsView.view.topAnchor.constraint(equalTo: todaysBitesCollectionView.bottomAnchor, constant: 20),
            vaccineCardsView.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            vaccineCardsView.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            vaccineCardsView.view.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        if let lastConstraint = contentView.constraints.first(where: { $0.firstAttribute == .bottom }) {
            lastConstraint.isActive = false
        }
        
        contentView.bottomAnchor.constraint(equalTo: vaccineCardsView.view.bottomAnchor, constant: 20).isActive = true
        
        vaccineView = vaccineCardsView.view
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
    @objc private func updateTodaysBites() {
        print("✅ Fetching Today's Bites from UserDefaults...")
        
        guard let savedMeals = UserDefaults.standard.array(forKey: "todaysBites") as? [[String: String]],
              let savedDate = UserDefaults.standard.string(forKey: "selectedDay") else {
            print("⚠️ No saved meals found!")
            return
        }
        print("📌 Saved Meals: \(savedMeals)")
        print("📌 Saved Date: \(savedDate)")
        var updatedBites: [TodayBite] = []
        
        for meal in savedMeals {
            if let title = meal["category"], let time = meal["time"], let imageName = meal["image"] {
                updatedBites.append(TodayBite(title: title, time: time, imageName: imageName))
            }
        }
        let predefinedOrder: [String] = ["EarlyBite", "NourishBite", "MidDayBite", "SnackBite", "NightBite"]
        updatedBites.sort { (a, b) -> Bool in
            let indexA = predefinedOrder.firstIndex(of: a.title) ?? predefinedOrder.count
            let indexB = predefinedOrder.firstIndex(of: b.title) ?? predefinedOrder.count
            return indexA < indexB
        }
        todaysBitesData = updatedBites
        todaysBitesCollectionView.reloadData()
    }
    @objc private func handleNewVaccineScheduled(_ notification: Notification) {
        loadVaccinations()
    }
    
    private func removeEmbeddedView() {
        for subview in specialMomentsContainerView.subviews {
            subview.removeFromSuperview()
        }
        for child in children {
            if child is SpecialMomentsViewController {
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
            }
        }
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

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return todaysBitesData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BitesCell", for: indexPath) as? TodayBiteCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let bite = todaysBitesData[indexPath.row]
        cell.configure(with: bite)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 250, height: 190)
    }
}
