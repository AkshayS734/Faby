import UIKit
import SwiftUI

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
        scrollView.backgroundColor = UIColor(hex: "#f2f2f7")
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: "#f2f2f7")
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
        view.backgroundColor = UIColor(hex: "#f2f2f7")
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
        collectionView.backgroundColor = UIColor(hex: "#f2f2f7")
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
            
            todaysBitesLabel.topAnchor.constraint(equalTo: specialMomentsContainerView.bottomAnchor, constant: 20),
            todaysBitesLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            todaysBitesCollectionView.topAnchor.constraint(equalTo: todaysBitesLabel.bottomAnchor, constant: 10),
            todaysBitesCollectionView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            todaysBitesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            todaysBitesCollectionView.heightAnchor.constraint(equalToConstant: 190)
        ])
    }
    
    private func setupVaccineView() {
        // First, remove any existing vaccine view
        vaccineView?.removeFromSuperview()
        
        // Remove the existing child view controller if it exists
        if let oldVaccineViewController = children.first(where: { $0 is UIHostingController<VaccineCardsView> }) {
            oldVaccineViewController.willMove(toParent: nil)
            oldVaccineViewController.view.removeFromSuperview()
            oldVaccineViewController.removeFromParent()
        }
        
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
        vaccineCardsView.view.backgroundColor = UIColor(hex: "#f2f2f7")
        
        // Add it after the today's bites collection view
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
        
        // Update the content view's bottom constraint
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

// Required supporting structures
struct TodayBite {
    let title: String
    let time: String
    let imageName: String
}

struct VaccineCardsView: View {
    var vaccines: [[String: String]]
    var onVaccineCompleted: ([String: String]) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Using UIViewRepresentable to get exact UILabel styling match
            UILabelRepresentable(text: "Vaccine Reminder", font: UIFont.boldSystemFont(ofSize: 20))
                .frame(height: 24)  // Approximate height for the label
                .padding(.horizontal, 16)
            
            if vaccines.isEmpty {
                // Empty state with centered message
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        Text("No vaccines added yet")
                            .font(.system(size: 16))
                            .foregroundColor(Color(.systemGray))
                            .frame(width: geometry.size.width, alignment: .center)
                        Spacer()
                    }
                }
                .frame(height: 120)
                .background(Color(UIColor(hex: "#f2f2f7")))
            } else {
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
                .frame(height: 120)
            }
        }
        .frame(height: 200)
        .background(Color(UIColor(hex: "#f2f2f7")))
    }
}

// UIViewRepresentable to ensure exact match with UIKit's UIFont.boldSystemFont
struct UILabelRepresentable: UIViewRepresentable {
    var text: String
    var font: UIFont
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.text = text
        uiView.font = font
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
        .background(Color(.systemBackground)) // This keeps the cards white
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
