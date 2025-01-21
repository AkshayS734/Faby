import UIKit
import SwiftUI
import Combine
// ViewController to manage the calendar and vaccine alert UI
class VacciAlertViewController: UIViewController {
    // Publisher to send the selected date
    private let selectedDateSubject = PassthroughSubject<Date, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize CalendarContainerView inside a UIHostingController
        let calendarView = UIHostingController(rootView:
            CalendarContainerView(
                selectedDate: selectedDateSubject.eraseToAnyPublisher(), // Pass the selected date publisher
                onChevronTapped: showDatePicker // Action to show date picker
            )
        )
        
        // Add the calendar view to the parent view controller
        addChild(calendarView)
        calendarView.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendarView.view)
        calendarView.didMove(toParent: self)
        
        // Setup constraints for calendar view
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
            performSegue(withIdentifier: "vaccineInfo", sender: vaccine)
        }
        
        // Prepare for segue to pass data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowVaccineDetail",
           let detailVC = segue.destination as? VaccineDetailViewController,
           let vaccine = sender as? String {
            detailVC.vaccineNameLabel.text = vaccine // Assign the string to the text property of the UILabel
        }
        }
    
}
// SwiftUI View to display the calendar and vaccine details
struct CalendarContainerView: View {
    let selectedDate: AnyPublisher<Date, Never> // Publisher for the selected date
    var onChevronTapped: () -> Void // Action for chevron button (to show date picker)
    @State private var currentDate: Date = Date() // Store the current selected date
    @State private var upcomingVaccinations: [String] = ["Hepatitis Vaccination", "Influenza"] // List of upcoming vaccinations
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Calendar View Section
                CalendarView(selectedDate: currentDate, onChevronTapped: onChevronTapped)
                
                // Latest Research Section header
                Text("Latest Research")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                
                // Horizontal Scroll for vaccine cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        // Vaccine card views for Hepatitis B and Influenza
                        VaccineCardView(
                            title: "Hepatitis B",
                            description: "The hepatitis B vaccine prevents liver disease and cancer.",
                            imageName: "hepatitisB" // Image for Hepatitis B from assets
                        )
                        VaccineCardView(
                            title: "Influenza",
                            description: "The influenza vaccine reduces the risk of flu infection.",
                            imageName: "influenza" // Image for Influenza from assets
                        )
                    }
                    .padding(.horizontal)
                }
                
                // Upcoming Vaccination Section header
                Text("Upcoming Vaccination")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                
                // List of upcoming vaccinations
                VStack(spacing: 8) {
                    ForEach(upcomingVaccinations, id: \.self) { vaccine in
                        HStack {
                            Text(vaccine)
                                .font(.body)
                            Spacer()
                            Button(action: {
                                print("\(vaccine) selected") // Action when vaccine is selected
                            }) {
                                Image(systemName: vaccine == "Hepatitis Vaccination" ? "plus" : "plus")
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
            currentDate = date // Update the current date when the publisher emits a new date
        }
    }
}
// SwiftUI View to display individual vaccine cards
struct VaccineCardView: View {
    let title: String
    let description: String
    let imageName: String // Image name passed as a parameter
    var body: some View {
        VStack(alignment: .leading) {
            // Load the image from the assets using the provided image name
            Image(imageName) // Use the passed image name to load the image from assets
                .resizable()
                .scaledToFit()
                .frame(height: 50) // Set the height of the image
                .padding(.bottom, 8)
            
            // Title of the vaccine
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            // Description of the vaccine
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 200)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
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
    

