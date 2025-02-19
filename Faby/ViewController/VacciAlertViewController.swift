import UIKit
import SwiftUI
import Combine

// MARK: - Calendar View
struct CalendarView: View {
    var selectedDate: Date
    var onChevronTappedToNavigate: () -> Void
    
    @State private var currentDay: Int = Calendar.current.component(.day, from: Date())
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(Color(UIColor(hex: "#0076BA")))
                Text(monthYearString(from: selectedDate))
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button(action: onChevronTappedToNavigate) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(1...31, id: \.self) { day in
                            VStack(spacing: 4) {
                                Text("\(day)")
                                    .font(.body)
                                    .fontWeight(isDaySelected(day) ? .semibold : .regular)
                                    .foregroundColor(isDaySelected(day) ? .white : .primary)
                                    .frame(width: 36, height: 36)
                                    .background(isDaySelected(day) ? Color(UIColor(hex: "#0076BA")) : Color.clear)
                                    .clipShape(Circle())
                            }
                            .id(day)
                        }
                    }
                    .padding(.horizontal)
                }
                .onAppear {
                    proxy.scrollTo(currentDay, anchor: .center)
                }
            }
        }
        .padding(.top)
    }
    private func isDaySelected(_ day: Int) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: selectedDate)
        return components.day == day
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Calendar Container View
struct CalendarContainerView: View {
    let selectedDate: AnyPublisher<Date, Never>
    var onChevronTappedToNavigate: () -> Void
    var onCardTapped: (String) -> Void
    var vaccineData: [VaccineData]
    
    @State private var currentDate: Date = Date()
    
    var body: some View {
        ZStack {
            Color(UIColor(hex: "#f2f2f7"))
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    CalendarView(
                        selectedDate: currentDate,
                        onChevronTappedToNavigate: onChevronTappedToNavigate
                    )
                    
                    if !vaccineData.isEmpty {
                        Text("Next Immunization")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ForEach(vaccineData.filter { !$0.isScheduled }, id: \.name) { vaccine in
                                VaccineCardView(vaccine: vaccine) {
                                    onCardTapped(vaccine.name)
                                }
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        Text("No upcoming vaccinations for the next 6 months")
                            .font(.body)
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(.vertical)
            }
        }
    }
}

// MARK: - Vaccine Card View
struct VaccineCardView: View {
    let vaccine: VaccineData
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading) {
                    Text(vaccine.name)
                        .font(.body)
                        .foregroundColor(.black)
                    
                    Text(formatDateRange(vaccine.startDate, vaccine.endDate))
                        .font(.subheadline)
                        .foregroundColor(.gray) // Change subtitle color to system gray
                }
                Spacer()
                Image(systemName: "plus.circle")
                    .foregroundColor(Color(UIColor(hex: "#0076BA")))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
        }
    }

    private func formatDateRange(_ startDate: Date, _ endDate: Date) -> String {
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

// MARK: - VacciAlert View Controller

class VacciAlertViewController: UIViewController {
    // MARK: - Properties
    private let selectedDateSubject = PassthroughSubject<Date, Never>()
    private var babyBirthDate: Date
    private var vaccineDataDict: [String: VaccineData] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    var selectedVaccines: [String] = [] {
        didSet {
            setupVaccineData()
        }
    }
    
    // MARK: - Initialization
    init() {
        // Set baby's birth date to exactly 1 year ago
        let calendar = Calendar.current
        self.babyBirthDate = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupVaccineData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        navigationItem.hidesBackButton = true
        navigationItem.title = "VacciTime"
        view.backgroundColor = UIColor(hex: "#f2f2f7")
        
        let calendarContainer = UIHostingController(rootView:
            CalendarContainerView(
                selectedDate: selectedDateSubject.eraseToAnyPublisher(),
                onChevronTappedToNavigate: { [weak self] in
                    self?.navigateToVaccineReminderViewController()
                },
                onCardTapped: { [weak self] vaccine in
                    self?.handleVaccineScheduling(vaccine)
                },
                vaccineData: []
            )
        )
        
        addChild(calendarContainer)
        calendarContainer.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendarContainer.view)
        calendarContainer.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            calendarContainer.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarContainer.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarContainer.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarContainer.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Data Management
    private func setupVaccineData() {
        let calendar = Calendar.current
        let babyAgeInMonths = 12 // Fixed at 1 year for now

        vaccineDataDict.removeAll()

        // Updated vaccine schedule
        let timelines: [(name: String, startMonth: Int, endMonth: Int)] = [
            // Newborn vaccines
            ("Hepatitis B (Dose 1)", 0, 1),
            ("RSV Antibody", 0, 1),

            // 2-month vaccines
            ("Hepatitis B (Dose 2)", 2, 3),
            ("Rotavirus (Dose 1)", 2, 3),
            ("DTaP (Dose 1)", 2, 3),
            ("Hib (Dose 1)", 2, 3),
            ("PCV (Dose 1)", 2, 3),
            ("IPV (Dose 1)", 2, 3),

            // 4-month vaccines
            ("Rotavirus (Dose 2)", 4, 5),
            ("DTaP (Dose 2)", 4, 5),
            ("Hib (Dose 2)", 4, 5),
            ("PCV (Dose 2)", 4, 5),
            ("IPV (Dose 2)", 4, 5),

            // 6-month vaccines
            ("Hepatitis B (Dose 3)", 6, 7),
            ("Rotavirus (Dose 3)", 6, 7), // Only if doing the three-dose series
            ("DTaP (Dose 3)", 6, 7),
            ("Hib (Dose 3)", 6, 7), // Only if doing the four-dose series
            ("PCV (Dose 3)", 6, 7),
            ("IPV (Dose 3)", 6, 7),
            ("Flu Vaccine", 6, 7),
            ("COVID-19 Vaccine", 6, 7),

            // 12-month vaccines
            ("MMR (Dose 1)", 12, 15),
            ("Hepatitis A (Dose 1)", 12, 15),
            ("PCV (Dose 4)", 12, 15),

            // 15-month vaccines
            ("Varicella (Dose 1)", 15, 18),
            ("DTaP (Dose 4)", 15, 18),
            ("Hib (Final Dose)", 15, 18), // Dose 3 or 4 depending on the series

            // 18-month vaccines
            ("Hepatitis A (Dose 2)", 18, 24)
        ]

        // Populate the vaccineDataDict
        for timeline in timelines {
            if timeline.startMonth >= babyAgeInMonths &&
               timeline.startMonth <= babyAgeInMonths + 3 && // Adjust window as needed
               !selectedVaccines.contains(timeline.name) {

                let vaccineStartDate = calendar.date(byAdding: .month, value: timeline.startMonth, to: babyBirthDate) ?? Date()
                let vaccineEndDate = calendar.date(byAdding: .month, value: timeline.endMonth, to: babyBirthDate) ?? Date()

                vaccineDataDict[timeline.name] = VaccineData(
                    name: timeline.name,
                    startDate: vaccineStartDate,
                    endDate: vaccineEndDate,
                    isScheduled: false
                )
            }
        }

        updateUIState()
    }
    private func updateUIState() {
        let sortedVaccines = vaccineDataDict.values.sorted { $0.startDate < $1.startDate }
        let calendarContainer = children.first as? UIHostingController<CalendarContainerView>
        let updatedView = CalendarContainerView(
            selectedDate: selectedDateSubject.eraseToAnyPublisher(),
            onChevronTappedToNavigate: { [weak self] in
                self?.navigateToVaccineReminderViewController()
            },
            onCardTapped: { [weak self] vaccine in
                self?.handleVaccineScheduling(vaccine)
            },
            vaccineData: sortedVaccines
        )
        calendarContainer?.rootView = updatedView
    }
    
    private func handleVaccineScheduling(_ vaccine: String) {
        if var vaccineData = vaccineDataDict[vaccine] {
            vaccineData.isScheduled = true
            vaccineDataDict[vaccine] = vaccineData
            selectedVaccines.append(vaccine)
            updateUIState()
            showAddVaccinationModal(for: vaccine)
        }
    }
    
    // MARK: - Navigation
    private func navigateToVaccineReminderViewController() {
        let reminderVC = VaccineReminderViewController()
        show(reminderVC, sender: self)
    }
    
    private func showAddVaccinationModal(for vaccine: String) {
        let hospitalVC = HospitalViewController()
        hospitalVC.vaccineName = vaccine
        hospitalVC.modalPresentationStyle = .pageSheet
        present(hospitalVC, animated: true)
    }
}


