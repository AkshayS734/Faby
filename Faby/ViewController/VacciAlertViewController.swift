import UIKit
import SwiftUI
import Combine
import CoreLocation
import Foundation
import Supabase

// MARK: - Vaccine Card View
struct VaccineCardView: View {
    let vaccine: Vaccine
    let babyBirthDate: Date
    let onTap: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric var scaledPadding: CGFloat = 16
    
    // Fixed height for all cards
    private let cardHeight: CGFloat = 100
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(vaccine.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(formatDateRange(startWeek: vaccine.startWeek, endWeek: vaccine.endWeek, birthDate: babyBirthDate, recommendedAgeText: vaccine.recommendedAgeText))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
                
                Spacer()
                
                Image(systemName: "calendar.badge.plus")
                    .font(.title3)
                    .foregroundColor(Color.accentColor)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .padding(.horizontal, 16)
            .frame(height: cardHeight, alignment: .center)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.1 : 0.05),
                    radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func formatDateRange(startWeek: Int, endWeek: Int, birthDate: Date, recommendedAgeText: String? = nil) -> String {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: startWeek * 7, to: birthDate) ?? Date()
        let endDate = calendar.date(byAdding: .day, value: endWeek * 7, to: birthDate) ?? Date()
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        if let recommendedAgeText = recommendedAgeText, !recommendedAgeText.isEmpty {
            if startDate < Date() && endDate < Date() {
                return "Overdue since \(recommendedAgeText)"
            }
            if startDate < Date() && endDate >= Date() {
                return "Due now until \(recommendedAgeText)"
            }
            return "Recommended before \(recommendedAgeText)"
        } else {
            // Fallback to date-based formatting if no recommendedAgeText is available
            if startDate < Date() && endDate < Date() {
                return "Overdue since \(formatter.string(from: endDate))"
            }
            if startDate < Date() && endDate >= Date() {
                return "Due now until \(formatter.string(from: endDate))"
            }
            return "Due \(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        }
    }
}
//
//  VacciAlertViewController.swift
//  Faby
//
//  Created by Adarsh Mishra on 14/05/25.
//

// MARK: - SwiftUI Vaccine List View
struct VaccineListView: View {
    let vaccines: [Vaccine]
    let babyBirthDate: Date
    let onVaccineTap: (Vaccine) -> Void
    let refreshAction: () -> Void
    var isLoading: Bool
    
    var body: some View {
        ZStack {
            ScrollView {
                if vaccines.isEmpty && !isLoading {
                    EmptyStateView()
                        .padding(.top, 100) // Add padding to make empty state more visible
                } else {
                    VStack(spacing: 12) {
                        // Use ForEach directly instead of VaccinesList
                        ForEach(vaccines) { vaccine in
                            VaccineCardView(
                                vaccine: vaccine,
                                babyBirthDate: babyBirthDate,
                                onTap: { onVaccineTap(vaccine) }
                            )
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            
            // Apple-style loading indicator
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.3)
                        .padding()
                    Text("Loading...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground).opacity(0.7))
            }
        }
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

// Helper method to update loading state in the SwiftUI view
extension VacciAlertViewController {
    func updateLoadingState(_ isLoading: Bool) {
        // Update the hosting controller with new loading state
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let hostingController = self.vaccineListHostingController {
                // Create a new view with the updated loading state
                let updatedView = VaccineListView(
                    vaccines: hostingController.rootView.vaccines,
                    babyBirthDate: hostingController.rootView.babyBirthDate,
                    onVaccineTap: hostingController.rootView.onVaccineTap,
                    refreshAction: hostingController.rootView.refreshAction,
                    isLoading: isLoading
                )
                
                // Update the root view with animation
                UIView.transition(with: hostingController.view, duration: 0.25, options: .transitionCrossDissolve) {
                    hostingController.rootView = updatedView
                }
            }
        }
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
    private var isRefreshingData = false
    private var isLoading = false
    
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
        
        // Initial data load using current baby ID from UserDefaults
        Task {
            do {
                // Try to get current baby ID from UserDefaults
                if let currentBabyId = UserDefaultsManager.shared.currentBabyId {
                    // Get baby details from Supabase
                    let baby = try await fetchBaby(with: currentBabyId)
                    print("🔍 DEBUG: Loading data for current baby: \(baby.name)")
                    await MainActor.run {
                        processBabyData(baby)
                        loadVaccinesByTimePeriod("Birth")
                    }
                } else {
                    // Fetch first baby connected to parent
                    let baby = try await fetchFirstConnectedBaby()
                    print("🔍 DEBUG: Loading data for first baby: \(baby.name)")
                    await MainActor.run {
                        UserDefaultsManager.shared.currentBabyId = baby.babyID
                        processBabyData(baby)
                        loadVaccinesByTimePeriod("Birth")
                    }
                }
            } catch {
                print("❌ ERROR: Failed to load baby data: \(error)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ensure large title is set when this view appears
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        // Force the title display
        setNavigationTitle()
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
            itemSize: CGSize(width: 90, height: 90),  // Increased card size
            lineSpacing: 10  // Slightly increased spacing
        )
        timePeriodCollectionView.delegate = self
        view.addSubview(timePeriodCollectionView)
        
        // Setup time period collection view constraints
        timePeriodCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup empty state label
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateLabel)
        
        // Loading indicator removed
        
        // Apply consistent spacing per HIG
        NSLayoutConstraint.activate([
            // Move the collection view down a bit and start from the leading edge
            timePeriodCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            timePeriodCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timePeriodCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timePeriodCollectionView.heightAnchor.constraint(equalToConstant: 110),  // Increased height
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            // Loading indicator constraints removed
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
        print("🔍 DEBUG: Vaccine details: \(vaccines.map { "\($0.name) (\($0.id))" }.joined(separator: ", "))")
        
        // Remove any existing empty state message
        emptyStateLabel.isHidden = true
        
        // If we already have a hosting controller, just update its root view
        if let existingHostingController = vaccineListHostingController {
            print("🔄 DEBUG: Updating existing hosting controller")
            
            // Make sure the view is visible
            existingHostingController.view.isHidden = false
            
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
                    },
                    isLoading: self.isLoading
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
            },
            isLoading: isLoading
        )
        
        let hostingController = UIHostingController(rootView: vaccineListView)
        vaccineListHostingController = hostingController
        
        // Configure the hosting controller view
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .systemGroupedBackground
        
        // Add to view hierarchy
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // Set constraints with priority to ensure proper layout
        let topConstraint = hostingController.view.topAnchor.constraint(equalTo: timePeriodCollectionView.bottomAnchor, constant: 16)
        topConstraint.priority = .required
        
        NSLayoutConstraint.activate([
            topConstraint,
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Force layout update
        view.layoutIfNeeded()
    }
    
    // MARK: - TimePeriodCollectionViewDelegate
    func didSelectTimePeriod(_ period: String) {
        print("👆 DEBUG: Time period selected: \(period)")
        loadVaccinesByTimePeriod(period)
    }
    
    // MARK: - Data Loading
    private func loadBabyDataSilently() async {
        do {
            if let currentBabyId = UserDefaultsManager.shared.currentBabyId {
                // Get baby details from Supabase
                let baby = try await fetchBaby(with: currentBabyId)
                await MainActor.run {
                    processBabyData(baby)
                }
            } else {
                // Fetch first baby connected to parent
                let baby = try await fetchFirstConnectedBaby()
                await MainActor.run {
                    UserDefaultsManager.shared.currentBabyId = baby.babyID
                    processBabyData(baby)
                }
            }
        } catch {
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
        
        // Show loading state and hide empty state
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isLoading = true
            self.emptyStateLabel.isHidden = true
            self.updateLoadingState(true)
        }
        
        // Create new loading task
        currentLoadingTask = Task { [weak self] in
            guard let self = self else {
                print("❌ DEBUG: Self is nil")
                return
            }
            
            do {
                print("🔍 DEBUG: Starting to fetch data")
                
                // Always fetch the first connected baby for the current user
                // to ensure we're using the correct baby ID
                let baby: Baby
                do {
                    baby = try await fetchFirstConnectedBaby()
                    let currentBabyId = baby.babyID
                    
                    // Update the UserDefaults with the current baby ID
                    UserDefaultsManager.shared.currentBabyId = currentBabyId
                    
                    // Update baby birth date for correct age calculation
                    let inputFormatter = DateFormatter()
                    inputFormatter.dateFormat = "yyyy-MM-dd" // Updated format to match the data
                    
                    if let birthDate = inputFormatter.date(from: baby.dateOfBirth) {
                        await MainActor.run {
                            self.babyBirthDate = birthDate
                        }
                    } else {
                        // Try alternate format
                        inputFormatter.dateFormat = "ddMMyyyy"
                        if let birthDate = inputFormatter.date(from: baby.dateOfBirth) {
                            await MainActor.run {
                                self.babyBirthDate = birthDate
                            }
                        }
                    }
                    
                    print("✅ DEBUG: Successfully fetched current baby: \(baby.name) with ID: \(currentBabyId)")
                    print("📅 DEBUG: Baby birth date: \(self.babyBirthDate)")
                } catch {
                    print("❌ DEBUG: Could not find any connected baby: \(error.localizedDescription)")
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not find any connected baby: \(error.localizedDescription)"])
                }
                
                let currentBabyId = baby.babyID
                
                let (lowerWeeks, upperWeeks) = self.convertPeriodToWeeks(period)
                print("📊 DEBUG: Fetching vaccines for weeks \(lowerWeeks)-\(upperWeeks)")
                
                // Fetch all vaccines first
                let allVaccines = try await self.getAllVaccines()
                print("📋 DEBUG: Total vaccines in database: \(allVaccines.count)")
                
                // Log all vaccines for debugging
                for (index, vaccine) in allVaccines.enumerated() {
                    print("🔢 DEBUG: Vaccine \(index+1): \(vaccine.name), Weeks: \(vaccine.startWeek)-\(vaccine.endWeek)")
                }
                
                // Fetch scheduled vaccines
                let scheduledVaccines = try await VaccineScheduleManager.shared.fetchSchedules(forId: currentBabyId)
                print("📋 DEBUG: Total scheduled vaccines: \(scheduledVaccines.count)")
                
                if Task.isCancelled {
                    print("🚫 DEBUG: Task was cancelled")
                    return
                }
                
                // Process results
                let scheduledVaccineIds = scheduledVaccines.map { $0.vaccineId }
                
                // Filter by age range
                let ageAppropriateVaccines = allVaccines.filter { vaccine in
                    let isInRange = vaccine.startWeek >= lowerWeeks && vaccine.endWeek <= upperWeeks
                    print("🔍 DEBUG: Vaccine \(vaccine.name) in range \(lowerWeeks)-\(upperWeeks)? \(isInRange)")
                    return isInRange
                }
                
                print("📊 DEBUG: Age-appropriate vaccines: \(ageAppropriateVaccines.count)")
                
                // Filter out already scheduled vaccines
                let availableVaccines = ageAppropriateVaccines.filter { vaccine in
                    let isNotScheduled = !scheduledVaccineIds.contains(vaccine.id)
                    print("🔍 DEBUG: Vaccine \(vaccine.name) already scheduled? \(!isNotScheduled)")
                    return isNotScheduled
                }
                
                print("📊 DEBUG: Found \(availableVaccines.count) available vaccines")
                
                await MainActor.run {
                    print("🎯 DEBUG: Updating UI with vaccines")
                    
                    // Always update the vaccine data
                    self.vaccineData = availableVaccines
                    
                    if availableVaccines.isEmpty {
                        self.updateEmptyState("No vaccines found for \(period)")
                    } else {
                        self.setupVaccineListView(with: availableVaccines)
                        self.emptyStateLabel.isHidden = true
                    }
                    
                    // Reset refresh and loading states
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.isRefreshingData = false
                        self.isLoading = false
                        self.updateLoadingState(false)
                    }
                }
            } catch {
                print("❌ DEBUG: Error loading vaccines: \(error)")
                if !Task.isCancelled {
                    await MainActor.run {
                        // Show error state and stop loading
                        self.updateEmptyState("Error loading vaccines: \(error.localizedDescription)")
                        self.isRefreshingData = false
                        self.isLoading = false
                        self.updateLoadingState(false)
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
        
        // Prevent multiple refreshes in quick succession
        guard !isRefreshingData else {
            print("⏭️ DEBUG: Skipping refresh - already in progress")
            return
        }
        
        // Get currently selected period
        let selectedPeriod = timePeriods[timePeriodCollectionView.selectedIndex]
        print("🔄 DEBUG: Refreshing data for period: \(selectedPeriod)")
        
        isRefreshingData = true
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
            // Create a custom detent that's between medium and large for a comfortable size
            if #available(iOS 16.0, *) {
                // Custom height that feels good - about 65% of screen height
                let customDetent = UISheetPresentationController.Detent.custom { context in
                    return context.maximumDetentValue * 0.65
                }
                sheet.detents = [customDetent, .medium(), .large()]
                sheet.selectedDetentIdentifier = customDetent.identifier
            } else {
                // Fallback for iOS 15 - use medium but make it a bit larger
                sheet.detents = [.medium(), .large()]
                sheet.selectedDetentIdentifier = .medium
            }
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
        
        present(hospitalVC, animated: true)
    }
    
    // Helper method to ensure we have a current baby ID
    private func ensureCurrentBabyIdIsSet() {
        // Check if a current baby ID is already set
        if UserDefaultsManager.shared.currentBabyId == nil {
            // If not set, fetch the first baby connected to parent
            Task {
                do {
                    let baby = try await fetchFirstConnectedBaby()
                    print("🔧 No current baby ID set, using first baby: \(baby.name) (ID: \(baby.babyID))")
                    UserDefaultsManager.shared.currentBabyId = baby.babyID
                } catch {
                     print("⚠️ Error fetching connected baby: \(error)")
                }
            }
        } else {
            print("✅ Current baby ID already set: \(UserDefaultsManager.shared.currentBabyId!)")
        }
    }
    
  
}

