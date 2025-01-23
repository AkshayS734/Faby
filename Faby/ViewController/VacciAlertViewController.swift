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
        
        // Initialize CalendarContainerView inside a UIHostingController
        
        let calendarView = UIHostingController(rootView:
            CalendarContainerView(
                selectedDate: selectedDateSubject.eraseToAnyPublisher(),
                onChevronTapped: showDatePicker,
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
        if vaccine == "Influenza"{
            detailVC.vaccineNameLabel.text = "Influenza"
            detailVC.vaccineDescriptionLabel.text="The flu is a contagious respiratory illness caused by influenza viruses. The vaccine protects against severe complications."
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
    var onChevronTapped: () -> Void
    var onCardTapped: (String) -> Void
    var onAddVaccinationTapped: () -> Void
    
    @State private var currentDate: Date = Date()
    @State private var upcomingVaccinations: [String] = ["Hepatitis Vaccination", "Influenza"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CalendarView(selectedDate: currentDate, onChevronTapped: onChevronTapped)

                Text("Latest Research")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        VaccineCardView(
                            title: "Hepatitis B",
                            description: "The hepatitis B vaccine prevents liver disease and cancer.",
                            imageName: "hepatitisB",
                            onTap: { onCardTapped("Hepatitis B") }
                        )
                        VaccineCardView(
                            title: "Influenza",
                            description: "The influenza vaccine reduces the risk of flu infection.",
                            imageName: "influenza",
                            onTap: { onCardTapped("Influenza") }
                        )
                    }
                    .padding(.horizontal)
                }

                Text("Upcoming Vaccination")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)

                VStack(spacing: 8) {
                    ForEach(upcomingVaccinations, id: \.self) { vaccine in
                        HStack {
                            Text(vaccine)
                                .font(.body)
                            Spacer()
                            Button(action: {
                                onAddVaccinationTapped()
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .onReceive(selectedDate) { date in
            currentDate = date
        }
    }
}

// SwiftUI View to display individual vaccine cards
struct VaccineCardView: View {
    let title: String
    let description: String
    let imageName: String
    let onTap: () -> Void // Closure to handle tap action

    var body: some View {
        VStack(alignment: .leading) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .padding(.bottom, 8)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 200)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .onTapGesture { // Handle tap on the card
            onTap()
        }
    }
}
// SwiftUI View to display the calendar and month/year header
struct CalendarView: View {
    var selectedDate: Date
    var onChevronTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            // Month and Year Section
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                Text(monthYearString(from: selectedDate)) // Display the month and year
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button(action: onChevronTapped) { // Button to show the date picker
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            // Horizontal Scrolling Date Section
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Create buttons for each day of the month
                    ForEach(1...31, id: \.self) { day in
                        let isSelected = isDaySelected(day) // Check if the day is selected
                        VStack(spacing: 4) {
                            Text(dayOfWeek(for: day)) // Display the day of the week
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Text("\(day)") // Display the day number
                                .font(.body)
                                .fontWeight(isSelected ? .semibold : .regular) // Bold if selected
                                .foregroundColor(isSelected ? .white : .primary)
                                .frame(width: 36, height: 36)
                                .background(isSelected ? Color.red : Color.clear) // Red background if selected
                                .clipShape(Circle()) // Circle shape for the day number
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }
    
    // Helper function to check if a day is selected
    private func isDaySelected(_ day: Int) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.day, from: selectedDate) == day
    }
    
    // Helper function to get the day of the week for a specific day
    private func dayOfWeek(for day: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        if let date = dateFormatter.date(from: "\(components.year ?? 2024)-\(components.month ?? 12)-\(String(format: "%02d", day))") {
            let dayNameFormatter = DateFormatter()
            dayNameFormatter.dateFormat = "E"
            return dayNameFormatter.string(from: date)
        }
        return ""
    }
    
    // Helper function to format the month and year string
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}
    

