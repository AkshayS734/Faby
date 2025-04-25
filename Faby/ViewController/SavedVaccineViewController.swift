import UIKit
import PDFKit
import Supabase

// MARK: - Supabase Vaccine Manager
class VaccineDataManager {
    static let shared = VaccineDataManager()
    
    private init() {}
    
    // Helper function to get Supabase client
    private func getSupabaseClient() -> SupabaseClient? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.supabase
        } else if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            return sceneDelegate.supabase
        }
        return nil
    }
    
    // Get all available vaccines from Supabase
    func fetchAllVaccines() async throws -> [Vaccine] {
        guard let supabase = getSupabaseClient() else {
            throw NSError(domain: "VaccineError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        let response = try await supabase.from("Vaccines")
            .select()
            .execute()
            
        return try JSONDecoder().decode([Vaccine].self, from: response.data)
    }
    
    // Get all vaccines scheduled for a specific baby
    func fetchVaccineSchedules(forBaby babyId: UUID) async throws -> [VaccineSchedule] {
        guard let supabase = getSupabaseClient() else {
            throw NSError(domain: "VaccineError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        let response = try await supabase.from("VaccineSchedules")
            .select()
            .eq("babyID", value: babyId.uuidString)
            .execute()
            
        return try JSONDecoder().decode([VaccineSchedule].self, from: response.data)
    }
    
    // Get all administered vaccines for a baby
    func fetchAdministeredVaccines(forBaby babyId: UUID) async throws -> [VaccineAdministered] {
        guard let supabase = getSupabaseClient() else {
            throw NSError(domain: "VaccineError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        let response = try await supabase.from("VaccineAdministered")
            .select()
            .eq("babyId", value: babyId.uuidString)
            .execute()
            
        return try JSONDecoder().decode([VaccineAdministered].self, from: response.data)
    }
    
    // Mark a vaccine as administered
    // Mark a vaccine as administered
    func addAdministeredVaccine(babyId: UUID, vaccineId: UUID, scheduleId: UUID? = nil, date: Date, location: String) async throws {
        guard let supabase = getSupabaseClient() else {
            throw NSError(domain: "VaccineError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        let record = VaccineAdministered(
            id: UUID(),
            babyId: babyId,
            vaccineId: vaccineId,
            scheduleId: scheduleId ?? UUID(),
            administeredDate: date
        )
        
        // Format date for Supabase compatibility
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateString = dateFormatter.string(from: date)
        
        // Create an Encodable struct for Supabase
        struct SupabaseVaccineRecord: Encodable {
            let id: String
            let babyId: String
            let vaccineId: String
            let scheduleId: String
            let administeredDate: String
        }
        
        let supabaseRecord = SupabaseVaccineRecord(
            id: record.id.uuidString,
            babyId: record.babyId.uuidString,
            vaccineId: record.vaccineId.uuidString,
            scheduleId: record.scheduleId.uuidString,
            administeredDate: dateString
        )
        
        try await supabase.from("VaccineAdministered")
            .insert(supabaseRecord)
            .execute()
    }
    // Delete an administered vaccine record
    func removeAdministeredVaccine(recordId: UUID) async throws {
        guard let supabase = getSupabaseClient() else {
            throw NSError(domain: "VaccineError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        try await supabase.from("VaccineAdministered")
            .delete()
            .eq("id", value: recordId.uuidString)
            .execute()
    }
}

class SavedVaccineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let emptyStateView = UIView()
    private let vaccineDataManager = VaccineDataManager.shared
    
    private var allVaccines: [Vaccine] = []
    private var vaccineSchedules: [VaccineSchedule] = []
    private var administeredVaccines: [VaccineAdministered] = []
    
    // For organizing the UI
    private var groupedVaccines: [String: [VaccineWithStatus]] = [:]
    private var ageGroups: [String] = []
    
    private var baby: Baby!
    
    // MARK: - Helper Struct for UI
    private struct VaccineWithStatus {
        let vaccine: Vaccine
        let isAdministered: Bool
        let administeredDate: Date?
        let vaccineAdministeredId: UUID?
        
        // Helper to determine display stage based on weeks
        var stageTitle: String {
            let weeks = vaccine.startWeek
            if weeks <= 6 {
                return "Birth to 6 Weeks"
            } else if weeks <= 10 {
                return "6 to 10 Weeks"
            } else if weeks <= 14 {
                return "10 to 14 Weeks"
            } else if weeks <= 24 {
                return "14 to 24 Weeks"
            } else if weeks <= 52 {
                return "24 to 52 Weeks"
            } else if weeks <= 104 {
                return "1 to 2 Years"
            } else {
                return "Over 2 Years"
            }
        }
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTableView()
        setupEmptyStateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSavedData()
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
    
    private func setupEmptyStateView() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)
        
        let noDataLabel = UILabel()
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        noDataLabel.text = "No vaccination records found"
        noDataLabel.textAlignment = .center
        noDataLabel.textColor = .secondaryLabel
        emptyStateView.addSubview(noDataLabel)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor),
            emptyStateView.heightAnchor.constraint(equalToConstant: 100),
            
            noDataLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor),
            noDataLabel.widthAnchor.constraint(equalTo: emptyStateView.widthAnchor, constant: -40)
        ])
        
        emptyStateView.isHidden = true
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
    private func loadSavedData() {
        showLoadingIndicator()
        
        Task {
            do {
                // Get the current baby
                if !BabyDataModel.shared.babyList.isEmpty {
                    baby = BabyDataModel.shared.babyList[0]
                    
                    // Load all data concurrently
                    async let allVaccinesTask = vaccineDataManager.fetchAllVaccines()
                    async let schedulesTask = vaccineDataManager.fetchVaccineSchedules(forBaby: baby.babyID)
                    async let administeredTask = vaccineDataManager.fetchAdministeredVaccines(forBaby: baby.babyID)
                    
                    // Wait for all to complete
                    (allVaccines, vaccineSchedules, administeredVaccines) = try await (allVaccinesTask, schedulesTask, administeredTask)
                    
                    // Process the data for display
                    processVaccineData()
                    
                    await MainActor.run {
                        hideLoadingIndicator()
                        
                        if self.administeredVaccines.isEmpty {
                            self.emptyStateView.isHidden = false
                            self.tableView.isHidden = true
                        } else {
                            self.emptyStateView.isHidden = true
                            self.tableView.isHidden = false
                            self.tableView.reloadData()
                        }
                    }
                } else {
                    await MainActor.run {
                        hideLoadingIndicator()
                        self.emptyStateView.isHidden = false
                        self.tableView.isHidden = true
                    }
                }
            } catch {
                print("❌ Error loading vaccines from Supabase: \(error)")
                await MainActor.run {
                    hideLoadingIndicator()
                    showErrorMessage("Failed to load vaccination records: \(error.localizedDescription)")
                    self.emptyStateView.isHidden = false
                    self.tableView.isHidden = true
                }
            }
        }
    }
    
    private func processVaccineData() {
        // Create VaccineWithStatus objects by combining data
        var vaccinesWithStatus: [VaccineWithStatus] = []
        
        for vaccine in allVaccines {
            // Find if this vaccine has been administered
            let administered = administeredVaccines.first { $0.vaccineId == vaccine.id }
            
            vaccinesWithStatus.append(VaccineWithStatus(
                vaccine: vaccine,
                isAdministered: administered != nil,
                administeredDate: administered?.administeredDate,
                vaccineAdministeredId: administered?.id
            ))
        }
        
        // Only show administered vaccines
        let administeredVaccinesWithStatus = vaccinesWithStatus.filter { $0.isAdministered }
        
        // Group by stage
        groupedVaccines = Dictionary(grouping: administeredVaccinesWithStatus) { $0.stageTitle }
        
        // Set up age groups for sections
        ageGroups = Array(groupedVaccines.keys).sorted { (group1, group2) -> Bool in
            // Sort age groups by start week
            let weekRanges = [
                "Birth to 6 Weeks": 0,
                "6 to 10 Weeks": 6,
                "10 to 14 Weeks": 10,
                "14 to 24 Weeks": 14,
                "24 to 52 Weeks": 24,
                "1 to 2 Years": 52,
                "Over 2 Years": 104
            ]
            
            return (weekRanges[group1] ?? 0) < (weekRanges[group2] ?? 0)
        }
    }
    
    private func saveVaccineDate(_ date: Date, for vaccineWithStatus: VaccineWithStatus) {
        showLoadingIndicator()
        
        Task {
            do {
                // If already administered, update it
                if let existingId = vaccineWithStatus.vaccineAdministeredId {
                    // Remove the old record
                    try await vaccineDataManager.removeAdministeredVaccine(recordId: existingId)
                }
                
                // Create a new record
                try await vaccineDataManager.addAdministeredVaccine(
                    babyId: baby.babyID,
                    vaccineId: vaccineWithStatus.vaccine.id,
                    date: date,
                    location: "Added manually"
                )
                
                // Reload data to get the updated records
                await loadSavedData()
                
                await MainActor.run {
                    hideLoadingIndicator()
                    showSuccessMessage("Vaccination date saved successfully")
                }
            } catch {
                await MainActor.run {
                    hideLoadingIndicator()
                    showErrorMessage("Failed to save vaccination date: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return ageGroups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let ageGroup = ageGroups[section]
        return groupedVaccines[ageGroup]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let ageGroup = ageGroups[section]
        return groupedVaccines[ageGroup]?.isEmpty == false ? ageGroup : nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VaccineCell", for: indexPath) as! VaccineTableViewCell
        
        let ageGroup = ageGroups[indexPath.section]
        if let vaccinesInGroup = groupedVaccines[ageGroup] {
            let vaccineWithStatus = vaccinesInGroup[indexPath.row]
            
            // Get formatted date for display
            var displayDate = "Not administered yet"
            if let administeredDate = vaccineWithStatus.administeredDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                displayDate = dateFormatter.string(from: administeredDate)
            }
            
            cell.configure(vaccineName: vaccineWithStatus.vaccine.name, date: displayDate)
            cell.onOptionsButtonTapped = { [weak self] in
                self?.showDatePicker(for: vaccineWithStatus)
            }
        }
        
        return cell
    }
    
    // MARK: - Table View Editing
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ageGroup = ageGroups[indexPath.section]
            guard var vaccinesInGroup = groupedVaccines[ageGroup],
                  indexPath.row < vaccinesInGroup.count else { return }
            
            let vaccineToDelete = vaccinesInGroup[indexPath.row]
            
            let alert = UIAlertController(
                title: "Delete Vaccine Record",
                message: "Are you sure you want to remove \(vaccineToDelete.vaccine.name) from your vaccination record?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                guard let self = self,
                      let vaccineAdministeredId = vaccineToDelete.vaccineAdministeredId else { return }
                
                self.showLoadingIndicator()
                
                Task {
                    do {
                        // Remove from Supabase
                        try await self.vaccineDataManager.removeAdministeredVaccine(recordId: vaccineAdministeredId)
                        
                        // Reload all data
                        await self.loadSavedData()
                        
                        await MainActor.run {
                            self.hideLoadingIndicator()
                            self.showSuccessMessage("Vaccination record removed successfully")
                        }
                    } catch {
                        await MainActor.run {
                            self.hideLoadingIndicator()
                            self.showErrorMessage("Failed to remove vaccination record: \(error.localizedDescription)")
                        }
                    }
                }
            })
            
            present(alert, animated: true)
        }
    }
    
    // MARK: - Date Picker
    private func showDatePicker(for vaccineWithStatus: VaccineWithStatus) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let titleLabel = UILabel()
        titleLabel.text = "Select Vaccination Date"
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        if let existingDate = vaccineWithStatus.administeredDate {
            datePicker.date = existingDate
        }
        
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
            self?.saveVaccineDate(datePicker.date, for: vaccineWithStatus)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - PDF Export
    @objc private func downloadTapped() {
        guard !administeredVaccines.isEmpty else {
            showAlert(title: "No Data", message: "There are no vaccination records to export")
            return
        }
        
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
            
            let title = "Vaccination Records"
            let titleSize = title.size(withAttributes: titleAttributes)
            let titleRect = CGRect(
                x: (pageWidth - titleSize.width) / 2,
                y: 50,
                width: titleSize.width,
                height: titleSize.height
            )
            title.draw(in: titleRect, withAttributes: titleAttributes)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let currentDate = "Generated on: \(dateFormatter.string(from: Date()))"
            currentDate.draw(
                at: CGPoint(x: 50, y: titleRect.maxY + 20),
                withAttributes: dateAttributes
            )
            
            var yPosition: CGFloat = titleRect.maxY + 60
            
            for ageGroup in ageGroups {
                if let vaccinesInGroup = groupedVaccines[ageGroup], !vaccinesInGroup.isEmpty {
                    let stageAttributes = [
                        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)
                    ]
                    ageGroup.draw(
                        at: CGPoint(x: 50, y: yPosition),
                        withAttributes: stageAttributes
                    )
                    yPosition += 25
                    
                    for vaccineWithStatus in vaccinesInGroup {
                        let vaccineAttributes = [
                            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)
                        ]
                        
                        vaccineWithStatus.vaccine.name.draw(
                            at: CGPoint(x: 70, y: yPosition),
                            withAttributes: vaccineAttributes
                        )
                        
                        if let date = vaccineWithStatus.administeredDate {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateStyle = .medium
                            let dateString = dateFormatter.string(from: date)
                            dateString.draw(
                                at: CGPoint(x: pageWidth - 200, y: yPosition),
                                withAttributes: vaccineAttributes
                            )
                        } else {
                            "Not administered".draw(
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
    
    // MARK: - Utility Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showLoadingIndicator() {
        // Add activity indicator if it doesn't exist
        if view.viewWithTag(999) == nil {
            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.startAnimating()
            activityIndicator.tag = 999
            
            view.addSubview(activityIndicator)
            
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
    }
    
    private func hideLoadingIndicator() {
        // Remove activity indicator
        if let activityIndicator = view.viewWithTag(999) as? UIActivityIndicatorView {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
    private func showSuccessMessage(_ message: String) {
        showAlert(title: "Success", message: message)
    }
    
    private func showErrorMessage(_ message: String) {
        showAlert(title: "Error", message: message)
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
    func configure(vaccineName: String, date: String? = nil) {
        vaccineLabel.text = vaccineName
        setDate(date)
    }
    
    func setDate(_ dateString: String?) {
        if let dateString = dateString, dateString != "Not administered yet" {
            dateLabel.text = "Administered on: \(dateString)"
            dateLabel.isHidden = false
        } else if let dateString = dateString {
            dateLabel.text = dateString
            dateLabel.isHidden = false
        } else {
            dateLabel.text = nil
            dateLabel.isHidden = true
        }
    }
}
