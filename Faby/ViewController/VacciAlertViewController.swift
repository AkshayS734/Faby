import UIKit
import SwiftUI
import Combine
import CoreLocation

// MARK: - Vaccine Card View
struct VaccineCardView: View {
    let vaccine: Vaccine
    let babyBirthDate: Date
    let onTap: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric var scaledPadding: CGFloat = 16

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(vaccine.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(formatDateRange(startWeek: vaccine.startWeek, endWeek: vaccine.endWeek, birthDate: babyBirthDate))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "calendar.badge.plus")
                    .font(.title3)
                    .foregroundColor(Color.accentColor)
                    .frame(width: 44, height: 44) // Optimal tap target size
                    .contentShape(Rectangle())
            }
            .padding(scaledPadding)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.1 : 0.05),
                    radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle()) // Prevents default button styling
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
    let refreshAction: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric var scaledPadding: CGFloat = 16
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: scaledPadding) {
                Text("Available Vaccines")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.horizontal, scaledPadding)
                    .padding(.bottom, 8)
                    .accessibilityAddTraits(.isHeader)
                
                if vaccines.isEmpty {
                    EmptyStateView()
                } else {
                    VaccinesList(vaccines: vaccines, babyBirthDate: babyBirthDate, onVaccineTap: onVaccineTap)
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
}

struct VaccinesList: View {
    let vaccines: [Vaccine]
    let babyBirthDate: Date
    let onVaccineTap: (Vaccine) -> Void
    
    @ScaledMetric var scaledSpacing: CGFloat = 12
    
    var body: some View {
        LazyVStack(spacing: scaledSpacing) {
            ForEach(vaccines) { vaccine in
                VaccineCardView(
                    vaccine: vaccine,
                    babyBirthDate: babyBirthDate,
                    onTap: { onVaccineTap(vaccine) }
                )
                .padding(.horizontal, 16)
            }
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cross.case.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No vaccines found for this age range")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                
            Text("Try selecting a different time period")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// Pull-to-refresh control
struct RefreshControl: View {
    @Binding var isRefreshing: Bool
    let onRefresh: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.frame(in: .global).minY > 50 {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView()
                            .onAppear {
                                if !isRefreshing {
                                    isRefreshing = true
                                    onRefresh()
                                }
                            }
                        Spacer()
                    }
                    Spacer()
                }
            } else if geometry.frame(in: .global).minY > 0 {
                // Optional: Show a "pull to refresh" text here when user starts pulling
                Color.clear.preference(key: RefreshPreferenceKey.self, value: geometry.frame(in: .global).minY)
            }
        }
        .frame(height: isRefreshing ? 50 : 0)
    }
}

struct RefreshPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - VacciAlert View Controller
class VacciAlertViewController: UIViewController, TimePeriodCollectionViewDelegate {
    // MARK: - Properties
    private let selectedDateSubject = PassthroughSubject<Date, Never>()
    private var babyBirthDate: Date = Date()
    private var vaccineData: [Vaccine] = []
    private var scheduledVaccines: [String] = []
    private var cancellables = Set<AnyCancellable>()
    private var currentLoadingTask: Task<Void, Never>?
    
    // Cache for vaccines
    private var cachedAllVaccines: [Vaccine]?
    private var lastVaccinesFetchTime: Date?
    private let cacheDuration: TimeInterval = 300 // 5 minutes
    
    // Debounce timer
    private var debounceTimer: Timer?
    private let debounceInterval: TimeInterval = 0.5
    
    // New time period collection view
    private var timePeriodCollectionView: TimePeriodCollectionView!
    private let timePeriods = ["Birth", "6 weeks", "10 weeks", "14 weeks", "9-12 month", "16-24 month"]
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private var vaccineListHostingController: UIHostingController<VaccineListView>?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔍 DEBUG: viewDidLoad called")
        setupUI()
        setupNotifications()
        
        // Preload vaccines cache
        Task {
            do {
                _ = try await getAllVaccines()
            } catch {
                print("❌ DEBUG: Error preloading vaccines: \(error)")
            }
        }
        
        // Initial data load
        if let currentBaby = BabyDataModel.shared.babyList.first(where: { $0.babyID == UserDefaultsManager.shared.currentBabyId }) {
            print("🔍 DEBUG: Loading data for current baby: \(currentBaby.name)")
            processBabyData(currentBaby)
            loadVaccinesByTimePeriod("Birth")
        } else if let firstBaby = BabyDataModel.shared.babyList.first {
            print("🔍 DEBUG: Loading data for first baby: \(firstBaby.name)")
            UserDefaultsManager.shared.currentBabyId = firstBaby.babyID
            processBabyData(firstBaby)
            loadVaccinesByTimePeriod("Birth")
        }
    }
    
    private func setupNotifications() {
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
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        // Setup navigation bar
        navigationItem.hidesBackButton = true
        setNavigationTitle()
        
        // Replace the refresh button with a calendar/reminder button
        let reminderButton = UIBarButtonItem(
            image: UIImage(systemName: "calendar"),
            style: .plain,
            target: self,
            action: #selector(navigateToVaccineReminder)
        )
        navigationItem.rightBarButtonItem = reminderButton
        
        // Setup time period collection view with new component
        timePeriodCollectionView = TimePeriodCollectionView(
            timePeriods: timePeriods,
            itemSize: CGSize(width: 85, height: 85),
            lineSpacing: 8
        )
        timePeriodCollectionView.delegate = self
        view.addSubview(timePeriodCollectionView)
        
        // Setup time period collection view constraints
        timePeriodCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup empty state label
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateLabel)
        
        // Apply consistent spacing per HIG
        NSLayoutConstraint.activate([
            timePeriodCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            timePeriodCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            timePeriodCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timePeriodCollectionView.heightAnchor.constraint(equalToConstant: 90),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
        
        // Initialize the SwiftUI hosting controller with empty data
        setupVaccineListView(with: [])
    }
    
    private func setNavigationTitle() {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold),
        ]
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = titleAttributes
        navigationItem.title = "VacciTime"
        
        // Ensure the large title is always displayed
        navigationItem.largeTitleDisplayMode = .always
        
        // Update navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = titleAttributes
        appearance.backgroundColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        // Remove the separator line
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    private func setupVaccineListView(with vaccines: [Vaccine]) {
        print("🎨 DEBUG: Setting up vaccine list view with \(vaccines.count) vaccines")
        
        // If we already have a hosting controller, just update its root view
        if let existingHostingController = vaccineListHostingController {
            print("🔄 DEBUG: Updating existing hosting controller")
            
            // Use animation for smoother transitions
            UIView.transition(with: existingHostingController.view, duration: 0.25, options: .transitionCrossDissolve) {
                let updatedView = VaccineListView(
                    vaccines: vaccines,
                    babyBirthDate: self.babyBirthDate,
                    onVaccineTap: { [weak self] vaccine in
                        self?.handleVaccineScheduling(vaccine)
                    },
                    refreshAction: { [weak self] in
                        self?.refreshVaccinationData()
                    }
                )
                existingHostingController.rootView = updatedView
            }
            return
        }
        
        // Create new hosting controller for first time setup
        print("➕ DEBUG: Creating new hosting controller")
        let vaccineListView = VaccineListView(
            vaccines: vaccines,
            babyBirthDate: babyBirthDate,
            onVaccineTap: { [weak self] vaccine in
                self?.handleVaccineScheduling(vaccine)
            },
            refreshAction: { [weak self] in
                self?.refreshVaccinationData()
            }
        )
        
        let hostingController = UIHostingController(rootView: vaccineListView)
        vaccineListHostingController = hostingController
        
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: timePeriodCollectionView.bottomAnchor, constant: 16),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.view.backgroundColor = .systemGroupedBackground
    }
    
    // MARK: - TimePeriodCollectionViewDelegate
    func didSelectTimePeriod(_ period: String) {
        print("👆 DEBUG: Time period selected: \(period)")
        loadVaccinesByTimePeriod(period)
    }
    
    // MARK: - Data Loading
    private func loadBabyDataSilently() async {
        if let currentBabyId = UserDefaultsManager.shared.currentBabyId,
           let currentBaby = BabyDataModel.shared.babyList.first(where: { $0.babyID == currentBabyId }) {
            processBabyData(currentBaby)
        } else if let firstBaby = BabyDataModel.shared.babyList.first {
            UserDefaultsManager.shared.currentBabyId = firstBaby.babyID
            processBabyData(firstBaby)
        } else {
            await MainActor.run {
                updateEmptyState("No baby data available. Please add a baby first.")
            }
        }
    }
    
    private func processBabyData(_ baby: Baby) {
        print("🔍 DEBUG: Processing baby data")
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "ddMMyyyy"

        if let birthDate = inputFormatter.date(from: baby.dateOfBirth) {
            print("🔍 DEBUG: Successfully parsed birth date")
            self.babyBirthDate = birthDate
        } else {
            print("❌ DEBUG: Failed to parse birth date")
        }
    }
    
    private func loadVaccinesByTimePeriod(_ period: String) {
        print("📥 DEBUG: loadVaccinesByTimePeriod called for period: \(period)")
        
        // Cancel existing debounce timer
        debounceTimer?.invalidate()
        
        // Create new debounce timer
        debounceTimer = Timer.scheduledTimer(withTimeInterval: debounceInterval, repeats: false) { [weak self] _ in
            self?.executeLoadVaccines(period)
        }
    }
    
    private func executeLoadVaccines(_ period: String) {
        // Cancel any existing task
        if currentLoadingTask != nil {
            print("🚫 DEBUG: Cancelling existing task")
            currentLoadingTask?.cancel()
        }
        
        // Create new loading task
        currentLoadingTask = Task { [weak self] in
            guard let self = self else {
                print("❌ DEBUG: Self is nil")
                return
            }
            
            do {
                print("🔍 DEBUG: Starting to fetch data")
                guard let currentBabyId = UserDefaultsManager.shared.currentBabyId else {
                    print("❌ DEBUG: No baby ID found")
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No baby selected"])
                }
                
                let (lowerWeeks, upperWeeks) = self.convertPeriodToWeeks(period)
                print("📊 DEBUG: Fetching vaccines for weeks \(lowerWeeks)-\(upperWeeks)")
                
                async let allVaccinesTask = self.getAllVaccines()
                async let scheduledVaccinesTask = VaccineScheduleManager.shared.fetchSchedules(forBaby: currentBabyId)
                
                let (allVaccines, scheduledVaccines) = try await (allVaccinesTask, scheduledVaccinesTask)
                
                if Task.isCancelled {
                    print("🚫 DEBUG: Task was cancelled")
                    return
                }
                
                // Process results
                let scheduledVaccineIds = scheduledVaccines.map { $0.vaccineId }
                let ageAppropriateVaccines = allVaccines.filter { vaccine in
                    return vaccine.startWeek >= lowerWeeks && vaccine.endWeek <= upperWeeks
                }
                let availableVaccines = ageAppropriateVaccines.filter { vaccine in
                    !scheduledVaccineIds.contains(vaccine.id)
                }
                
                print("📊 DEBUG: Found \(availableVaccines.count) available vaccines")
                
                await MainActor.run {
                    print("🎯 DEBUG: Updating UI with vaccines")
                    if availableVaccines.isEmpty {
                        self.updateEmptyState("No vaccines found for \(period)")
                    } else {
                        self.vaccineData = availableVaccines
                        self.setupVaccineListView(with: availableVaccines)
                        self.emptyStateLabel.isHidden = true
                    }
                }
            } catch {
                print("❌ DEBUG: Error loading vaccines: \(error)")
                if !Task.isCancelled {
                    await MainActor.run {
                        self.updateEmptyState("Error loading vaccines: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func getAllVaccines() async throws -> [Vaccine] {
        // Check if we have a valid cache
        if let cached = cachedAllVaccines,
           let lastFetch = lastVaccinesFetchTime,
           Date().timeIntervalSince(lastFetch) < cacheDuration {
            print("📦 DEBUG: Using cached vaccines")
            return cached
    }
    
        // Fetch fresh data
        print("🔄 DEBUG: Fetching fresh vaccines data")
        let vaccines = try await FetchingVaccines.shared.fetchAllVaccines()
        
        // Update cache
        cachedAllVaccines = vaccines
        lastVaccinesFetchTime = Date()
        
        return vaccines
    }
    
    // Helper method to convert time period string to week range
    private func convertPeriodToWeeks(_ period: String) -> (Int, Int) {
        switch period {
        case "Birth":
            return (0, 4) // 0-4 weeks
            
        case "6 weeks":
            return (4, 8) // 4-8 weeks
            
        case "10 weeks":
            return (8, 12) // 8-12 weeks
            
        case "14 weeks":
            return (12, 16) // 12-16 weeks
            
        case "9-12 month":
            // 9-12 months = 36-52 weeks
            return (36, 52)
            
        case "16-24 month":
            // 16-24 months = 64-104 weeks
            return (64, 104)
            
        default:
            // Default range - covers first year
            return (0, 52)
        }
    }
    
    private func updateEmptyState(_ message: String) {
        vaccineListHostingController?.view.isHidden = true
        emptyStateLabel.isHidden = false
        emptyStateLabel.text = message
    }
    
    @objc private func refreshVaccinationData() {
        print("🔄 DEBUG: refreshVaccinationData called")
        // Get currently selected period
        let selectedPeriod = timePeriods[timePeriodCollectionView.selectedIndex]
        print("🔄 DEBUG: Refreshing data for period: \(selectedPeriod)")
        loadVaccinesByTimePeriod(selectedPeriod)
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
        
        // Use a sheet presentation controller for better visual style
        if let sheet = hospitalVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
        
        present(hospitalVC, animated: true)
    }
    
    // Helper method to ensure we have a current baby ID
    private func ensureCurrentBabyIdIsSet() {
        // Check if a current baby ID is already set
        if UserDefaultsManager.shared.currentBabyId == nil {
            // If not set, use the first baby in the list (if available)
            if let firstBaby = BabyDataModel.shared.babyList.first {
                print("🔧 No current baby ID set, using first baby: \(firstBaby.name) (ID: \(firstBaby.babyID))")
                UserDefaultsManager.shared.currentBabyId = firstBaby.babyID
            } else {
                print("⚠️ No babies in baby list, cannot set current baby ID")
            }
        } else {
            print("✅ Current baby ID already set: \(UserDefaultsManager.shared.currentBabyId!)")
        }
    }
}

