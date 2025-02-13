import UIKit
import SwiftUI
import Combine

// ViewController to manage the calendar and vaccine alert UI
class VacciAlertViewController: UIViewController {
    
    var selectedVaccines: [String] = []
    // Publisher to send the selected date
    private let selectedDateSubject = PassthroughSubject<Date, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true

        // Set the title
        navigationItem.title = "VacciTime"
        view.backgroundColor = UIColor(hex: "#f2f2f7")
        
        // Initialize CalendarContainerView inside a UIHostingController
        let calendarView = UIHostingController(rootView:
            CalendarContainerView(
                selectedDate: selectedDateSubject.eraseToAnyPublisher(),
                onChevronTappedToNavigate: { [weak self] in
                    self?.navigateToVaccineReminderViewController()
                },
                onCardTapped: { [weak self] vaccine in
                    self?.showVaccineDetail(for: vaccine)
                },
                onAddVaccinationTapped: { [weak self] in
                    self?.showAddVaccinationModal()
                }
            )
        )

        addChild(calendarView)
        calendarView.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendarView.view)
        calendarView.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            calendarView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            calendarView.view.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func navigateToVaccineReminderViewController() {
        let reminderVC = VaccineReminderViewController()
        show(reminderVC, sender: self)
    }
    
    // Date changed event handler when user selects a date from the date picker
    @objc func dateChanged(_ datePicker: UIDatePicker) {
        selectedDateSubject.send(datePicker.date) // Send the selected date to the publisher
    }
    
    // Show the DatePicker inside an action sheet
    func showDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.frame.size = CGSize(width: 0, height: 300) // Set the height of the date picker
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged) // Handle date change
        
        // Create UIAlertController with a custom height to accommodate the date picker
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        
        // Container view to hold the date picker inside the alert
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        alertController.view.addSubview(containerView)
        containerView.addSubview(datePicker)
        
        // Container view constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        // Date picker constraints to center it inside the container
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            datePicker.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            datePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // Action for selecting the date
        let selectAction = UIAlertAction(title: "Select", style: .default) { [weak self] _ in
            self?.selectedDateSubject.send(datePicker.date) // Send the selected date to the publisher
        }
        
        // Action for canceling the date selection
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add actions to the alert controller
        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)
        
        // Ensure there's enough space for the buttons
        alertController.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 380).isActive = true // Adjust height
        
        // Present the alert with the date picker
        present(alertController, animated: true)
    }
    
    // Handle segue to vaccine detail view
    func showVaccineDetail(for vaccine: String) {
        let detailVC = VaccineDetailViewController()
        
        // Pass vaccine details (example for "Hepatitis B")
        if vaccine == "Hepatitis B" {
            detailVC.vaccineNameLabel.text = "Hepatitis B"
            detailVC.vaccineDescriptionLabel.text = "Hepatitis is an inflammation of the liver. The vaccine protects against severe complications."
        }
        if vaccine == "Influenza" {
            detailVC.vaccineNameLabel.text = "Influenza"
            detailVC.vaccineDescriptionLabel.text = "The flu is a contagious respiratory illness caused by influenza viruses. The vaccine protects against severe complications."
        }
        
        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true, completion: nil)
    }
    
    // Prepare for segue to pass data
    func showAddVaccinationModal() {
        let detailVC = HospitalViewController()
        
        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true, completion: nil)
    }
}

// SwiftUI View to display the calendar and vaccine details
struct CalendarContainerView: View {
    let selectedDate: AnyPublisher<Date, Never>
    var onChevronTappedToNavigate: () -> Void
    var onCardTapped: (String) -> Void
    var onAddVaccinationTapped: () -> Void

    @State private var currentDate: Date = Date()
    @State private var upcomingVaccinations: [(name: String, startDate: Date, endDate: Date)] = [
        ("Hepatitis Vaccination", Date(), Calendar.current.date(byAdding: .day, value: 4, to: Date())!),
        ("Influenza", Calendar.current.date(byAdding: .day, value: 7, to: Date())!, Calendar.current.date(byAdding: .day, value: 10, to: Date())!)
    ]

    var body: some View {
        ZStack { // Add a ZStack to manage the background
            Color(UIColor(hex: "#f2f2f7")) // Set background color
                .ignoresSafeArea() // Extend to the edges of the screen

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    CalendarView(
                        selectedDate: currentDate,
                        onChevronTappedToNavigate: onChevronTappedToNavigate
                    )

                    Text("Next Immunization")

                        .font(.title2)
                        .bold()
                        .padding(.horizontal)

                    VStack(spacing: 8) {
                        ForEach(upcomingVaccinations, id: \.name) { vaccine in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(vaccine.name)
                                        .font(.body)
                                    Text(formatDateRange(from: vaccine.startDate, to: vaccine.endDate))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Button(action: {
                                    onAddVaccinationTapped()
                                }) {
                                    Image(systemName: "plus")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.white))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
    }

    private func formatDateRange(from startDate: Date, to endDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

// SwiftUI View to display the calendar and month/year header
struct CalendarView: View {
    var selectedDate: Date
    var onChevronTappedToNavigate: () -> Void // Navigation closure

    @State private var currentDay: Int = Calendar.current.component(.day, from: Date()) // Get today's day

    var body: some View {
        VStack(alignment: .leading) {
            // Month and Year Section
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(Color(UIColor(hex: "#0076BA")))
                Text(monthYearString(from: selectedDate)) // Display the month and year
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button(action: onChevronTappedToNavigate) { // Button to navigate
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)

            // Horizontal Scrolling Date Section
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(1...31, id: \.self) { day in
                            let isSelected = isDaySelected(day) // Check if the day is selected
                            VStack(spacing: 4) {
                                Text("\(day)") // Display the day number
                                    .font(.body)
                                    .fontWeight(isSelected ? .semibold : .regular) // Bold if selected
                                    .foregroundColor(isSelected ? .white : .primary)
                                    .frame(width: 36, height: 36)
                                    .background(isSelected ? Color(UIColor(hex: "#0076BA")) : Color.clear) // Blue background if selected
                                    .clipShape(Circle()) // Circle shape for the day number
                            }
                            .id(day) // Add an id to each day for scrolling
                        }
                    }
                    .padding(.horizontal)
                }
                .onAppear {
                    // Scroll to today's date when the view appears
                    proxy.scrollTo(currentDay, anchor: .center)
                }
            }
        }
        .padding(.top)
    }

    // Helper function to check if a day is selected
    func isDaySelected(_ day: Int) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: selectedDate)
        return components.day == day
    }

    // Helper function to format the month and year string
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}
