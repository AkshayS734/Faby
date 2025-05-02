import UIKit

class SelectedVaccinesViewController: UIViewController {
    
    // MARK: - Properties
    private var selectedVaccines: [Vaccine] = []
    
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
//        label.text = "Your Selected Vaccines"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Review your selections below"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let infoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    init(selectedVaccines: [Vaccine]) {
        self.selectedVaccines = selectedVaccines
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
        
        [titleLabel, subtitleLabel, stackView, infoView, continueButton].forEach {
            contentView.addSubview($0)
        }
        
        infoView.addSubview(infoLabel)
        

        
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
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            stackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            infoView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 24),
            infoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            infoLabel.topAnchor.constraint(equalTo: infoView.topAnchor, constant: 16),
            infoLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -16),
            infoLabel.bottomAnchor.constraint(equalTo: infoView.bottomAnchor, constant: -16),
            
            continueButton.topAnchor.constraint(equalTo: infoView.bottomAnchor, constant: 24),
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
        
        // Update info label
        infoLabel.text = "You have selected \(selectedVaccines.count) vaccines. Please review the schedule and requirements for each vaccine carefully."
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
        
        let ageLabel = UILabel()
        ageLabel.text = "Age: \(getAgeText(for: vaccine))"
        ageLabel.font = .systemFont(ofSize: 15)
        ageLabel.textColor = .secondaryLabel
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronImageView.tintColor = .systemGray3
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(iconView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(ageLabel)
        cardView.addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(equalToConstant: 80),
            
            iconView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -16),
            
            ageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            ageLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            ageLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -16),
            
            chevronImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(vaccineCardTapped(_:)))
        cardView.addGestureRecognizer(tapGesture)
        cardView.isUserInteractionEnabled = true
        
        return cardView
    }
    
    private func getAgeText(for vaccine: Vaccine) -> String {
        if vaccine.startWeek == 0 {
            return "At birth"
        } else if vaccine.startWeek < 52 {
            return "\(vaccine.startWeek/4) months"
        } else {
            let years = vaccine.startWeek / 52
            return "\(years) years"
        }
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
            content += "<p>Age: \(getAgeText(for: vaccine))</p>"
            content += "<p>\(vaccine.description)</p>"
            content += "</div>"
        }
        
        return content
    }
    
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
        // Implement vaccine detail view navigation
    }
}
