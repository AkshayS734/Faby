import UIKit
import SwiftUI

//struct Vaccination {
//    let title: String
//    let date: String
//    let location: String
//    var isChecked: Bool
//}

struct TodayBite {
    let title: String
    let time: String
    let imageName: String
}

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    var scheduledVaccines: [[String: String]] = []
    var completedVaccines: [[String: String]] = []
    var vaccineView: UIView?
    var baby = BabyDataModel.shared.babyList[0]
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor(hex: "#f2f2f7")
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
    
    var todaysBitesData: [TodayBite] = [
        TodayBite(title: "Early Bite", time: "7:30 AM - 8:00 AM", imageName: "Mashed Banana with Milk"),
        TodayBite(title: "Nourish Bite", time: "10:00 AM - 10:30 AM", imageName: "Poha with Vegetables"),
        TodayBite(title: "Midday Bite", time: "1:00 PM - 1:30 AM", imageName: "Spinach Dal with Rice"),
        TodayBite(title: "Snack Bite", time: "4:00 PM - 4:30 PM", imageName: "Vegetable Pulao"),
        TodayBite(title: "Night Bite", time: "7:30 PM - 8:00 PM", imageName: "Gobhi Aloo With Roti")
    ]
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#f2f2f7")
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .plain,
            target: self,
            action: #selector(goToSettings)
        )
        NotificationCenter.default.addObserver(self, selector: #selector(updateSpecialMoments), name: .milestonesAchievedUpdated, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewVaccineScheduled),
            name: NSNotification.Name("NewVaccineScheduled"),
            object: nil
        )
        
        todaysBitesCollectionView.register(UINib(nibName: "TodayBiteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BitesCell")
        
        setupUI()
        setupDelegates()
        loadVaccinations()
        updateNameLabel()
        updateDateLabel()
        embedSpecialMomentsViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadVaccinations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(specialMomentsLabel)
        contentView.addSubview(specialMomentsContainerView)
        contentView.addSubview(todaysBitesLabel)
        contentView.addSubview(todaysBitesCollectionView)
        
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
            todaysBitesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            todaysBitesCollectionView.heightAnchor.constraint(equalToConstant: 190)
        ])
    }
    
    private func setupVaccineView() {
        vaccineView?.removeFromSuperview()
        
        let vaccineCardsView = UIHostingController(rootView:
            VaccineCardsView(
                vaccines: scheduledVaccines,
                onVaccineCompleted: { [weak self] vaccine in
                    if let index = self?.scheduledVaccines.firstIndex(where: { $0 == vaccine }) {
                        self?.scheduledVaccines.remove(at: index)
                        self?.completedVaccines.append(vaccine)
                        
                        UserDefaults.standard.set(self?.scheduledVaccines, forKey: "VaccinationSchedules")
                        UserDefaults.standard.set(self?.completedVaccines, forKey: "CompletedVaccines")
                        UserDefaults.standard.synchronize()
                        
                        self?.loadVaccinations()
                    }
                }
            )
        )
        
        addChild(vaccineCardsView)
        vaccineCardsView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(vaccineCardsView.view)
        vaccineCardsView.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            vaccineCardsView.view.topAnchor.constraint(equalTo: todaysBitesCollectionView.bottomAnchor, constant: 20),
            vaccineCardsView.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            vaccineCardsView.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            vaccineCardsView.view.heightAnchor.constraint(equalToConstant: 200),
            vaccineCardsView.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
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
    
    private func loadVaccinations() {
        if let savedScheduled = UserDefaults.standard.array(forKey: "VaccinationSchedules") as? [[String: String]] {
            scheduledVaccines = savedScheduled
            setupVaccineView()
        }
        
        if let savedCompleted = UserDefaults.standard.array(forKey: "CompletedVaccines") as? [[String: String]] {
            completedVaccines = savedCompleted
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
    
    // MARK: - Action Methods
    @objc func goToSettings() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc func updateSpecialMoments() {
        embedSpecialMomentsViewController()
    }
    
    @objc private func handleNewVaccineScheduled(_ notification: Notification) {
        loadVaccinations()
    }
}

// MARK: - CollectionView Extensions
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

// MARK: - SwiftUI Views
struct VaccineCardsView: View {
    var vaccines: [[String: String]]
    var onVaccineCompleted: ([String: String]) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vaccine Reminder")
                .font(.system(size: 20, weight: .bold)) // Set font size to 20 and weight to bold
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vaccines, id: \.self) { vaccine in
                        VaccineCard(
                            vaccine: vaccine,
                            onComplete: {
                                onVaccineCompleted(vaccine)
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
            }
        }
        .background(Color(UIColor(hex: "#f2f2f7")))
    }
}

struct VaccineCard: View {
    var vaccine: [String: String]
    var onComplete: () -> Void
    @State private var isCompleted = false
    @State private var opacity = 1.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with Type and Completion Button
            HStack {
                Text(vaccine["type"] ?? "Unknown Vaccine")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isCompleted = true
                        opacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onComplete()
                    }
                }) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isCompleted ? .green : Color(.systemGray3))
                        .font(.system(size: 22))
                }
                .disabled(isCompleted)
            }
            
            // Date and Hospital Info
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .foregroundColor(Color(.systemBlue))
                        .font(.system(size: 14))
                    Text(vaccine["date"] ?? "")
                        .font(.subheadline)
                        .foregroundColor(Color(.systemGray))
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "building.2")
                        .foregroundColor(Color(.systemBlue))
                        .font(.system(size: 14))
                    Text(vaccine["hospital"] ?? "Unknown Hospital")
                        .font(.subheadline)
                        .foregroundColor(Color(.systemGray))
                }
            }
        }
        .padding(16)
        .frame(width: 260, height: 120)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color(.systemGray4).opacity(0.5), radius: 4, x: 0, y: 2)
        .opacity(opacity)
    }
}
// Make Dictionary conform to Hashable
extension Dictionary: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.description)
    }
}
