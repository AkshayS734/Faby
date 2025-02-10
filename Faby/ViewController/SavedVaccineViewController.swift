import UIKit
import PDFKit

class SavedVaccineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let vaccineManager = VaccineManager.shared
    private var groupedVaccines: [String: [String]] = [:]
    private var stages: [String] = []
    private var vaccineDates: [String: Date] = [:]
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTableView()
        loadAndGroupVaccines()
        loadVaccineDates()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Vaccination History"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.down"),
            style: .plain,
            target: self,
            action: #selector(downloadTapped)
        )
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(VaccineTableViewCell.self, forCellReuseIdentifier: "VaccineCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Data Management
    private func loadAndGroupVaccines() {
        stages = ["Birth", "2 Months", "4 Months", "6 Months", "12 Months", "15 Months", "18 Months"]
        
        groupedVaccines = [
            "Birth": ["BCG", "Hepatitis B (Dose 1)"],
            "2 Months": ["DTaP (Dose 1)", "IPV (Dose 1)", "Hib (Dose 1)", "PCV13 (Dose 1)", "Rotavirus (Dose 1)"],
            "4 Months": ["DTaP (Dose 2)", "IPV (Dose 2)", "Hib (Dose 2)", "PCV13 (Dose 2)", "Rotavirus (Dose 2)"],
            "6 Months": ["DTaP (Dose 3)", "IPV (Dose 3)", "Hib (Dose 3)", "PCV13 (Dose 3)", "Hepatitis B (Dose 3)"],
            "12 Months": ["MMR (Dose 1)", "Varicella (Dose 1)", "Hepatitis A (Dose 1)"],
            "15 Months": ["DTaP (Dose 4)", "Hib (Dose 4)"],
            "18 Months": ["Hepatitis A (Dose 2)"]
        ]
    }
    
    private func loadVaccineDates() {
        if let savedDates = UserDefaults.standard.dictionary(forKey: "VaccineDates") as? [String: Double] {
            vaccineDates = savedDates.mapValues { Date(timeIntervalSince1970: $0) }
        }
    }
    
    private func saveVaccineDate(_ date: Date, for vaccine: String) {
        vaccineDates[vaccine] = date
        let datesToSave = vaccineDates.mapValues { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(datesToSave, forKey: "VaccineDates")
        tableView.reloadData()
    }
    
    // MARK: - Date Picker
    private func showDatePicker(for vaccine: String) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Create title label with custom styling
        let titleLabel = UILabel()
        titleLabel.text = "Select Vaccination Date"
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create date picker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        if let existingDate = vaccineDates[vaccine] {
            datePicker.date = existingDate
        }
        
        // Add title and date picker to alert
        alert.view.addSubview(titleLabel)
        alert.view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -16),
            
            datePicker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 8),
            datePicker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -8),
            datePicker.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // Make alert taller to accommodate title and date picker
        let constraintHeight = NSLayoutConstraint(
            item: alert.view!,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 320
        )
        alert.view.addConstraint(constraintHeight)
        
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            self?.saveVaccineDate(datePicker.date, for: vaccine)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - PDF Export
    @objc private func downloadTapped() {
        guard let pdfData = generatePDF() else {
            showAlert(title: "Error", message: "Could not generate PDF")
            return
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Vaccination_Records.pdf")
        try? pdfData.write(to: tempURL)
        
        let activityViewController = UIActivityViewController(
            activityItems: [tempURL],
            applicationActivities: nil
        )
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(activityViewController, animated: true)
    }
    
    private func generatePDF() -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Vaccination Tracker",
            kCGPDFContextAuthor: "Your App Name",
            kCGPDFContextTitle: "Vaccination Records"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth: CGFloat = 8.5 * 72.0
        let pageHeight: CGFloat = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            let titleAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)
            ]
            let dateAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)
            ]
            
            // Add header
            let title = "Vaccination Records"
            let titleSize = title.size(withAttributes: titleAttributes)
            let titleRect = CGRect(
                x: (pageWidth - titleSize.width) / 2,
                y: 50,
                width: titleSize.width,
                height: titleSize.height
            )
            title.draw(in: titleRect, withAttributes: titleAttributes)
            
            // Add date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let currentDate = "Generated on: \(dateFormatter.string(from: Date()))"
            currentDate.draw(
                at: CGPoint(x: 50, y: titleRect.maxY + 20),
                withAttributes: dateAttributes
            )
            
            // Draw vaccination records
            var yPosition: CGFloat = titleRect.maxY + 60
            
            for stage in stages {
                let stageAttributes = [
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)
                ]
                stage.draw(
                    at: CGPoint(x: 50, y: yPosition),
                    withAttributes: stageAttributes
                )
                yPosition += 25
                
                if let vaccines = groupedVaccines[stage] {
                    for vaccine in vaccines {
                        let vaccineAttributes = [
                            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)
                        ]
                        
                        vaccine.draw(
                            at: CGPoint(x: 70, y: yPosition),
                            withAttributes: vaccineAttributes
                        )
                        
                        if let date = vaccineDates[vaccine] {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateStyle = .medium
                            let dateString = dateFormatter.string(from: date)
                            dateString.draw(
                                at: CGPoint(x: pageWidth - 200, y: yPosition),
                                withAttributes: vaccineAttributes
                            )
                        }
                        
                        yPosition += 20
                    }
                    yPosition += 10
                }
                
                if yPosition > pageHeight - 100 {
                    context.beginPage()
                    yPosition = 50
                }
            }
        }
        
        return data
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return stages.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let stage = stages[section]
        return groupedVaccines[stage]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return stages[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VaccineCell", for: indexPath) as! VaccineTableViewCell
        
        let stage = stages[indexPath.section]
        if let vaccines = groupedVaccines[stage] {
            let vaccine = vaccines[indexPath.row]
            
            cell.configure(with: vaccine)
            
            if let date = vaccineDates[vaccine] {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                cell.setDate(dateFormatter.string(from: date))
            } else {
                cell.setDate(nil)
            }
            
            cell.onOptionsButtonTapped = { [weak self] in
                self?.showDatePicker(for: vaccine)
            }
        }
        
        return cell
    }
}

// MARK: - VaccineTableViewCell
class VaccineTableViewCell: UITableViewCell {
    private let vaccineLabel = UILabel()
    private let dateLabel = UILabel()
    private let optionsButton = UIButton()
    var onOptionsButtonTapped: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        vaccineLabel.font = .systemFont(ofSize: 17, weight: .regular)
        vaccineLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(vaccineLabel)
        
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .systemGray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)
        
        optionsButton.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        optionsButton.tintColor = .systemBlue
        optionsButton.addTarget(self, action: #selector(optionsButtonTapped), for: .touchUpInside)
        optionsButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(optionsButton)
        
        NSLayoutConstraint.activate([
            vaccineLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            vaccineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            vaccineLabel.trailingAnchor.constraint(equalTo: optionsButton.leadingAnchor, constant: -8),
            
            dateLabel.topAnchor.constraint(equalTo: vaccineLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: vaccineLabel.leadingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            optionsButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            optionsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            optionsButton.widthAnchor.constraint(equalToConstant: 32),
            optionsButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    // MARK: - Actions
    @objc private func optionsButtonTapped() {
        onOptionsButtonTapped?()
    }
    
    // MARK: - Configuration
    func configure(with vaccineName: String) {
        vaccineLabel.text = vaccineName
    }
    
    func setDate(_ dateString: String?) {
        if let dateString = dateString {
            dateLabel.text = "Administered on: \(dateString)"
            dateLabel.isHidden = false
        } else {
            dateLabel.text = nil
            dateLabel.isHidden = true
        }
    }
}
