import UIKit
import SwiftUI
import Combine
import CoreLocation

// MARK: - Vaccine Card View
struct VaccineCardView: View {
    let vaccine: Vaccine
    let babyBirthDate: Date
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading) {
                    Text(vaccine.name)
                        .font(.body)
                        .foregroundColor(.black)
                    
                    Text(formatDateRange(startWeek: vaccine.startWeek, endWeek: vaccine.endWeek, birthDate: babyBirthDate))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "plus.circle")
                    .foregroundColor(Color(UIColor(hex: "#0076BA")))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }
    
    private func formatDateRange(startWeek: Int, endWeek: Int, birthDate: Date) -> String {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: startWeek * 7, to: birthDate) ?? Date()
        let endDate = calendar.date(byAdding: .day, value: endWeek * 7, to: birthDate) ?? Date()
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        if startDate < Date() && endDate < Date() {
            return "Overdue since \(formatter.string(from: endDate))"
        }
        if startDate < Date() && endDate >= Date() {
            return "Due now until \(formatter.string(from: endDate))"
        }
        return "Due \(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

// MARK: - SwiftUI Vaccine List View
struct VaccineListView: View {
    let vaccines: [Vaccine]
    let babyBirthDate: Date
    let onVaccineTap: (Vaccine) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Available Vaccines")
                    .font(.headline)
                    .padding(.horizontal)
                
                if vaccines.isEmpty {
                    Text("No vaccines found for this age range")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(vaccines) { vaccine in
                        VaccineCardView(
                            vaccine: vaccine,
                            babyBirthDate: babyBirthDate,
                            onTap: { onVaccineTap(vaccine) }
                        )
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical,30)
        }
    }
}

// MARK: - VacciAlert View Controller
class VacciAlertViewController: UIViewController, ButtonsCollectionViewDelegate {
    // MARK: - Properties
    private let selectedDateSubject = PassthroughSubject<Date, Never>()
    private var babyBirthDate: Date = Date()
    private var vaccineData: [Vaccine] = []
    private var scheduledVaccines: [String] = []
    private var cancellables = Set<AnyCancellable>()
    private var monthButtonCollectionView: ButtonsCollectionView!
    private let monthButtonTitles = ["12 months", "15 months", "18 months", "24 months", "30 months", "36 months"]
    private let monthButtonSize = CGSize(width: 90, height: 100)
    
    // UI elements
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateLabel = UILabel()
    private var vaccineListHostingController: UIHostingController<VaccineListView>?
    
    // MARK: - Initialization
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Add notification observers
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(navigateToVaccineReminder),
            name: NSNotification.Name("NavigateToVaccineReminder"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshVaccinationData),
            name: .vaccinesUpdated,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshVaccinationData),
            name: .newVaccineScheduled,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh data when view appears
        loadBabyData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        navigationItem.hidesBackButton = true
        navigationItem.title = "VacciTime"
        view.backgroundColor = UIColor(hex: "#f2f2f7")
        
        // Add a refresh button to the navigation bar
        let refreshButton = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshVaccinationData)
        )
        navigationItem.rightBarButtonItem = refreshButton
        
        // Setup month button collection view
        monthButtonCollectionView = ButtonsCollectionView(
            buttonTitles: monthButtonTitles,
            categoryButtonTitles: [],
            categoryButtonImages: [],
            buttonSize: monthButtonSize,
            minimumLineSpacing: 5,
            cornerRadius: 10
        )
        monthButtonCollectionView.delegate = self
        view.addSubview(monthButtonCollectionView)
        
        // Setup month collection view constraints
        monthButtonCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            monthButtonCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            monthButtonCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            monthButtonCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            monthButtonCollectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // Setup activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor(hex: "#0076BA")
        view.addSubview(activityIndicator)
        
        // Setup empty state label
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .gray
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.font = UIFont.systemFont(ofSize: 16)
        emptyStateLabel.isHidden = true
        view.addSubview(emptyStateLabel)
        
        // Set constraints
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Initialize the SwiftUI hosting controller with empty data
        setupVaccineListView(with: [])
    }
    
    private func setupVaccineListView(with vaccines: [Vaccine]) {
        // If we already have a hosting controller, remove it
        if let existingHostingController = vaccineListHostingController {
            existingHostingController.willMove(toParent: nil)
            existingHostingController.view.removeFromSuperview()
            existingHostingController.removeFromParent()
        }
        
        // Create SwiftUI view
        let vaccineListView = VaccineListView(
            vaccines: vaccines,
            babyBirthDate: babyBirthDate,
            onVaccineTap: { [weak self] vaccine in
                self?.handleVaccineScheduling(vaccine)
            }
        )
        
        // Create hosting controller
        let hostingController = UIHostingController(rootView: vaccineListView)
        vaccineListHostingController = hostingController
        
        // Add as child view controller
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // Set constraints
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: monthButtonCollectionView.bottomAnchor, constant: 20),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.view.backgroundColor = UIColor(hex: "#f2f2f7")
    }
    
    // MARK: - Button Collection View Delegate
    func didSelectButton(withTitle title: String, inCollection collection: ButtonsCollectionView) {
        print("Button Tapped: \(title)")
        loadVaccinesByAge(monthString: title)
    }
    
    // MARK: - Data Loading
    private func loadBabyData() {
        // Get the current baby - in a real app, you would get this from your app state
        guard let currentBabyId = UserDefaultsManager.shared.currentBabyId,
              let currentBaby = BabyDataModel.shared.babyList.first(where: { $0.babyID == currentBabyId }) else {
            // Use the first baby as fallback
            if let firstBaby = BabyDataModel.shared.babyList.first {
                processBabyData(firstBaby)
            } else {
                print("❌ No baby data available")
                updateEmptyState("No baby data available. Please add a baby first.")
            }
            return
        }
        
        processBabyData(currentBaby)
    }
    
    private func processBabyData(_ baby: Baby) {
        // Convert string date to Date object
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "ddMMyyyy"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"

        if let birthDate = inputFormatter.date(from: baby.dateOfBirth) {
            self.babyBirthDate = birthDate
            let formattedDateString = outputFormatter.string(from: birthDate)
            print("Formatted date: \(formattedDateString)")
            loadVaccinationData(for: baby)
        } else {
            print("❌ Invalid date format for baby's birth date")
            updateEmptyState("Invalid date format for baby's birth date")
        }
    }
    
    private func loadVaccinationData(for baby: Baby) {
        Task {
            do {
                showLoading(true)
                
                // First, fetch scheduled vaccines for this baby
                let vaccineSchedules = try await VaccineScheduleManager.shared.fetchSchedules(forBaby: baby.babyID)
                
                // Extract the vaccine IDs that are already scheduled
                let scheduledVaccineIds = vaccineSchedules.map { $0.vaccineId }
                self.scheduledVaccines = scheduledVaccineIds.map { $0.uuidString }
                
                // Fetch all vaccines recommended for this baby's age
                let recommendedVaccines = try await FetchingVaccines.shared.fetchRecommendedVaccines(forBaby: baby)
                
                // Filter out vaccines that are already scheduled
                let upcomingVaccines = recommendedVaccines.filter { vaccine in
                    !scheduledVaccineIds.contains(vaccine.id)
                }
                
                // Update UI on main thread
                await MainActor.run {
                    self.vaccineData = upcomingVaccines
                    if upcomingVaccines.isEmpty {
                        self.updateEmptyState("No upcoming vaccines available")
                    } else {
                        print("✅ Successfully loaded \(upcomingVaccines.count) upcoming vaccines")
                        self.setupVaccineListView(with: upcomingVaccines)
                        self.emptyStateLabel.isHidden = true
                    }
                    self.showLoading(false)
                }
            } catch {
                print("❌ Error loading vaccination data: \(error.localizedDescription)")
                
                // Show error state
                await MainActor.run {
                    self.vaccineData = []
                    self.updateEmptyState("Error loading vaccination data: \(error.localizedDescription)")
                    self.showLoading(false)
                }
            }
        }
    }
    
    private func loadVaccinesByAge(monthString: String) {
        // Extract the number of months from the button title
        guard let monthsString = monthString.components(separatedBy: " ").first,
              let months = Int(monthsString) else {
            print("❌ Invalid month format: \(monthString)")
            return
        }
        
        print("🔍 Loading vaccines for \(months) months")
        showLoading(true)
        
        // Convert months to weeks for filtering
        let weeksLowerBound = (months - 3) * 4 // 3 months before
        let weeksUpperBound = (months + 3) * 4 // 3 months after
        
        Task {
            do {
                // Get the current baby
                guard let currentBabyId = UserDefaultsManager.shared.currentBabyId else {
                    print("❌ No current baby ID available")
                    await MainActor.run {
                        self.updateEmptyState("No baby selected")
                        self.showLoading(false)
                    }
                    return
                }
                
                // First, fetch scheduled vaccines for this baby
                let vaccineSchedules = try await VaccineScheduleManager.shared.fetchSchedules(forBaby: currentBabyId)
                
                // Extract the vaccine IDs that are already scheduled
                let scheduledVaccineIds = vaccineSchedules.map { $0.vaccineId }
                
                // Fetch all vaccines from Supabase
                let allVaccines = try await FetchingVaccines.shared.fetchAllVaccines()
                
                // Filter vaccines for the selected month range
                let ageAppropriateVaccines = allVaccines.filter { vaccine in
                    return vaccine.startWeek >= weeksLowerBound &&
                           vaccine.endWeek <= weeksUpperBound
                }
                
                // Further filter out already scheduled vaccines
                let availableVaccines = ageAppropriateVaccines.filter { vaccine in
                    !scheduledVaccineIds.contains(vaccine.id)
                }
                
                await MainActor.run {
                    if availableVaccines.isEmpty {
                        print("ℹ️ No vaccines found for \(months) months")
                        self.updateEmptyState("No vaccines found for \(months) months")
                    } else {
                        print("✅ Found \(availableVaccines.count) vaccines for \(months) months")
                        self.setupVaccineListView(with: availableVaccines)
                        self.emptyStateLabel.isHidden = true
                    }
                    self.showLoading(false)
                }
            } catch {
                print("❌ Error loading vaccines for \(months) months: \(error.localizedDescription)")
                await MainActor.run {
                    self.updateEmptyState("Error loading vaccines: \(error.localizedDescription)")
                    self.showLoading(false)
                }
            }
        }
    }
    
    private func showLoading(_ isLoading: Bool) {
        DispatchQueue.main.async {
            if isLoading {
                self.activityIndicator.startAnimating()
                self.vaccineListHostingController?.view.isHidden = true
                self.emptyStateLabel.isHidden = true
            } else {
                self.activityIndicator.stopAnimating()
                self.vaccineListHostingController?.view.isHidden = false
            }
        }
    }
    
    private func updateEmptyState(_ message: String) {
        emptyStateLabel.isHidden = false
        emptyStateLabel.text = message
        vaccineListHostingController?.view.isHidden = true
    }
    
    @objc private func refreshVaccinationData() {
        loadBabyData()
    }
    
    @objc private func navigateToVaccineReminder() {
        let reminderVC = VaccineReminderViewController()
        navigationController?.pushViewController(reminderVC, animated: true)
    }
    
    // MARK: - Actions
    private func handleVaccineScheduling(_ vaccine: Vaccine) {
        // Open the hospital selection view controller
        showAddVaccinationModal(for: vaccine)
    }
    
    // MARK: - Navigation
    private func showAddVaccinationModal(for vaccine: Vaccine) {
        let hospitalVC = HospitalViewController()
        hospitalVC.vaccine = vaccine
        hospitalVC.modalPresentationStyle = .pageSheet
        present(hospitalVC, animated: true)
    }
}
