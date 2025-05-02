import UIKit

class SelectedVaccinesViewController: UIViewController {
    
    // MARK: - Properties
    private var selectedVaccines: [Vaccine] = []
    private var selectedDates: [String: Date] = [:]
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    init(selectedVaccines: [Vaccine], selectedDates: [String: Date]) {
        self.selectedVaccines = selectedVaccines
        self.selectedDates = selectedDates
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupVaccineCards()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        scrollView.backgroundColor = .systemGroupedBackground
        contentView.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [stackView, continueButton].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            continueButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 24),
            continueButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 52),
            continueButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
        
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    private func setupNavigationBar() {
        title = "Selected Vaccines"
        
        // Left bar button (Reselect)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Reselect",
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        
        // Right bar button (Print)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "printer"),
            style: .plain,
            target: self,
            action: #selector(printButtonTapped)
        )
    }
    
    private func setupVaccineCards() {
        // Clear existing stack view content
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add vaccine cards
        for vaccine in selectedVaccines {
            let cardView = createVaccineCardView(for: vaccine)
            stackView.addArrangedSubview(cardView)
        }
    }
    
    private func createVaccineCardView(for vaccine: Vaccine) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        
        let iconView = UIImageView(image: UIImage(systemName: "syringe.fill"))
        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = vaccine.name
        nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create date components
        let calendarIcon = UIImageView(image: UIImage(systemName: "calendar.badge.clock"))
        calendarIcon.tintColor = .systemGreen
        calendarIcon.contentMode = .scaleAspectFit
        calendarIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let dateLabel = UILabel()
        
        // Check if there's a selected date for this vaccine
        if let selectedDate = selectedDates[vaccine.name] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateLabel.text = "Scheduled: \(dateFormatter.string(from: selectedDate))"
            dateLabel.textColor = .systemGreen
        } else {
            dateLabel.text = "Not scheduled"
            dateLabel.textColor = .secondaryLabel
        }
        
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(iconView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(calendarIcon)
        cardView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(equalToConstant: 70),
            
            iconView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            calendarIcon.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            calendarIcon.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            calendarIcon.widthAnchor.constraint(equalToConstant: 18),
            calendarIcon.heightAnchor.constraint(equalToConstant: 18),
            
            dateLabel.centerYAnchor.constraint(equalTo: calendarIcon.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: calendarIcon.trailingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16)
        ])
        
        // Add tap gesture only if there's no scheduled date
        if selectedDates[vaccine.name] == nil {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(vaccineCardTapped(_:)))
            cardView.addGestureRecognizer(tapGesture)
            cardView.isUserInteractionEnabled = true
        }
        
        return cardView
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func printButtonTapped() {
        // Create a print formatter for the content
        let formatter = UIMarkupTextPrintFormatter(markupText: generatePrintContent())
        
        // Create print controller
        let printController = UIPrintInteractionController.shared
        printController.printFormatter = formatter
        
        // Configure printing
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "Selected Vaccines"
        printController.printInfo = printInfo
        
        // Present printing options
        printController.present(animated: true)
    }
    
    private func generatePrintContent() -> String {
        var content = "<h1>Selected Vaccines</h1>"
        content += "<p>Total vaccines selected: \(selectedVaccines.count)</p>"
        
        for vaccine in selectedVaccines {
            content += "<div style='margin: 10px 0;'>"
            content += "<h3>\(vaccine.name)</h3>"
            
            // Add scheduled date if available
            if let scheduledDate = selectedDates[vaccine.name] {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .long
                content += "<p><strong>Scheduled: \(dateFormatter.string(from: scheduledDate))</strong></p>"
            } else {
                content += "<p>Not scheduled</p>"
            }
            
            content += "<p>\(vaccine.description)</p>"
            content += "</div>"
        }
        
        return content
    }

//    @objc private func continueButtonTapped() {
//            if selectedVaccines.isEmpty {
//                let noSelectionAlert = UIAlertController(
//                    title: "No Vaccines Selected",
//                    message: "Please select at least one vaccine to continue.",
//                    preferredStyle: .alert
//                )
//                noSelectionAlert.addAction(UIAlertAction(title: "OK", style: .default))
//                present(noSelectionAlert, animated: true)
//                return
//            }
//            
//            Task {
//                do {
//                    // Save selected vaccines to schedule
//                    for vaccine in selectedVaccines {
//                        try await VaccineScheduleManager.shared.saveSchedule(
//                            babyId: vaccine.id,
//                            vaccineId: vaccine.id,
//                            hospital: "To be selected",
//                            date: Date(),
//                            location: "To be selected"
//                        )
//                    }
//                    
//                    // Navigate to VacciAlertViewController on the main thread
//                    await MainActor.run {
//                        let vacciAlertVC = VacciAlertViewController()
//                        self.navigationController?.pushViewController(vacciAlertVC, animated: true)
//                        
//                        // Post notification to refresh vaccine data
//                        NotificationCenter.default.post(name: NSNotification.Name("RefreshVaccineData"), object: nil)
//                    }
//                } catch {
//                    print("Error saving vaccine schedules: \(error)")
//                    await MainActor.run {
//                        let alert = UIAlertController(
//                            title: "Error",
//                            message: "Failed to save vaccine schedules. Please try again.",
//                            preferredStyle: .alert
//                        )
//                        alert.addAction(UIAlertAction(title: "OK", style: .default))
//                        self.present(alert, animated: true)
//                    }
//                }
//            }
//        }

    
    // MARK: - Actions
    @objc private func continueButtonTapped() {
        if selectedVaccines.isEmpty {
            let noSelectionAlert = UIAlertController(
                title: "No Vaccines Selected",
                message: "Please select at least one vaccine to continue.",
                preferredStyle: .alert
            )
            noSelectionAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(noSelectionAlert, animated: true)
            return
        }
        
        Task {
            do {
                // Save selected vaccines to schedule
                for vaccine in selectedVaccines {
                    try await VaccineScheduleManager.shared.saveSchedule(
                        babyId: vaccine.id,
                        vaccineId: vaccine.id,
                        hospital: "To be selected",
                        date: Date(),
                        location: "To be selected"
                    )
                }
                
                // Navigate to VacciAlertViewController on the main thread
                await MainActor.run {
                    let vacciAlertVC = VacciAlertViewController()
                    self.navigationController?.pushViewController(vacciAlertVC, animated: true)
                    
                    // Post notification to refresh vaccine data
                    NotificationCenter.default.post(name: NSNotification.Name("RefreshVaccineData"), object: nil)
                }
            } catch {
                print("Error saving vaccine schedules: \(error)")
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Failed to save vaccine schedules. Please try again.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    @objc private func vaccineCardTapped(_ sender: UITapGestureRecognizer) {
        guard let cardView = sender.view,
              let index = stackView.arrangedSubviews.firstIndex(of: cardView),
              index < selectedVaccines.count else {
            return
        }
        
        let vaccine = selectedVaccines[index]
        // Implement vaccine detail view navigation if needed
    }
}
