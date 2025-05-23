import UIKit
import PDFKit
import Foundation
import Supabase
import CoreLocation
import MessageUI

class SavedVaccineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    // MARK: - UI Elements
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let emptyStateLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Data
    private var administeredVaccines: [VaccineAdministered] = []
    private var vaccines: [String: Vaccine] = [:] // Cache for vaccine details
    private var currentBabyId: String = ""  // Will fetch all babies' vaccines if empty
    
    // Organized vaccine data
    private var organizedVaccines: [(timeframe: String, vaccines: [VaccineAdministered])] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Vaccination Records"
        view.backgroundColor = .systemGroupedBackground
        
        setupUI()
        setupConstraints()
        setupNavigationBar()
        
        // Get baby ID from user defaults or other source
        if let babyId = UserDefaults.standard.string(forKey: "selectedBabyId") {
            currentBabyId = babyId
        }
        
        // Register for vaccine update notifications
        NotificationCenter.default.addObserver(self, selector: #selector(refreshVaccines), name: Notification.Name("VaccinesUpdated"), object: nil)
    }
    
    private func setupNavigationBar() {
        // Configure the navigation bar appearance
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // Create download button for vaccination records
        let downloadButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.down"),
            style: .plain,
            target: self,
            action: #selector(downloadVaccinationRecords)
        )
        
        navigationItem.rightBarButtonItem = downloadButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadVaccines()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Configure table view with iOS native style
        tableView.register(AdministeredVaccineCell.self, forCellReuseIdentifier: "AdministeredVaccineCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        
        // Setup section headers - smaller than before
        tableView.sectionHeaderHeight = 36
        tableView.estimatedSectionHeaderHeight = 36
        
        // Set autoresizing to false BEFORE adding to view hierarchy
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Configure empty state label
        emptyStateLabel.text = "No vaccination records found"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emptyStateLabel.isHidden = true
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateLabel)
        
        // Configure activity indicator
        activityIndicator.color = .systemBlue
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Table view constraints
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Empty state label constraints
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Activity indicator constraints
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Data Loading
    private func loadVaccines() {
        activityIndicator.startAnimating()
        tableView.isHidden = true
        emptyStateLabel.isHidden = true
        
        Task {
            do {
                // Fetch all vaccines first for reference
                let allVaccines = try await SupabaseVaccineManager.shared.fetchAllVaccines()
                
                for vaccine in allVaccines {
                    if let id = vaccine.id.uuidString as String? {
                        vaccines[id] = vaccine
                    }
                }
                
                // Always fetch the first connected baby for the current user
                // to ensure we're using the correct baby ID
                do {
                    let baby = try await fetchFirstConnectedBaby()
                    currentBabyId = baby.babyID.uuidString
                    
                    // Update the UserDefaults with the current baby ID
                    UserDefaultsManager.shared.currentBabyId = baby.babyID
                    
                    print("✅ Successfully fetched current baby: \(baby.name) with ID: \(currentBabyId)")
                } catch {
                    print("❌ Could not find any connected baby: \(error.localizedDescription)")
                    // Continue with empty baby ID to fetch all administered vaccines
                    currentBabyId = ""
                }
                
                // Fetch administered vaccines for all babies or specific baby
                if currentBabyId.isEmpty {
                    administeredVaccines = try await SupabaseVaccineManager.shared.fetchAllAdministeredVaccines()
                } else {
                    administeredVaccines = try await SupabaseVaccineManager.shared.fetchAdministeredVaccines(forBabyId: currentBabyId)
                }
                
                // Organize vaccines by timeframe
                organizeVaccinesByTimeframe()
                
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    
                    if administeredVaccines.isEmpty {
                        tableView.isHidden = true
                        emptyStateLabel.isHidden = false
                        emptyStateLabel.text = "No administered vaccines found"
                    } else {
                        tableView.isHidden = false
                        tableView.alpha = 1.0
                        emptyStateLabel.isHidden = true
                        
                        view.setNeedsLayout()
                        view.layoutIfNeeded()
                        
                        tableView.reloadData()
                    }
                }
            } catch {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    updateEmptyState(message: "Error loading vaccines: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Organize vaccines by timeframe
    private func organizeVaccinesByTimeframe() {
        // Group vaccines by their target timeframe
        var vaccinesByTimeframe: [String: [VaccineAdministered]] = [
            "BIRTH": [],
            "6 WEEKS": [],
            "10 WEEKS": [],
            "14 WEEKS": [],
            "6 MONTHS": [],
            "9 MONTHS": [],
            "12 MONTHS": [],
            "15 MONTHS": [],
            "18 MONTHS": [],
            "2 YEARS": [],
            "4-6 YEARS": [],
            "11-12 YEARS": []
        ]
        
        // Logic to determine which timeframe each vaccine belongs to
        for vaccine in administeredVaccines {
            let vaccineId = vaccine.vaccineId.uuidString
            if let vaccineInfo = vaccines[vaccineId] {
                // Use vaccine info to determine timeframe
                if vaccineInfo.startWeek == 0 {
                    vaccinesByTimeframe["BIRTH"]?.append(vaccine)
                } else if vaccineInfo.startWeek <= 6 {
                    vaccinesByTimeframe["6 WEEKS"]?.append(vaccine)
                } else if vaccineInfo.startWeek <= 10 {
                    vaccinesByTimeframe["10 WEEKS"]?.append(vaccine)
                } else if vaccineInfo.startWeek <= 14 {
                    vaccinesByTimeframe["14 WEEKS"]?.append(vaccine)
                } else if vaccineInfo.startWeek <= 26 { // ~6 months
                    vaccinesByTimeframe["6 MONTHS"]?.append(vaccine)
                } else if vaccineInfo.startWeek <= 39 { // ~9 months
                    vaccinesByTimeframe["9 MONTHS"]?.append(vaccine)
                } else if vaccineInfo.startWeek <= 52 { // ~12 months
                    vaccinesByTimeframe["12 MONTHS"]?.append(vaccine)
                } else if vaccineInfo.startWeek <= 65 { // ~15 months
                    vaccinesByTimeframe["15 MONTHS"]?.append(vaccine)
                } else if vaccineInfo.startWeek <= 78 { // ~18 months
                    vaccinesByTimeframe["18 MONTHS"]?.append(vaccine)
                } else if vaccineInfo.startWeek <= 104 { // ~2 years
                    vaccinesByTimeframe["2 YEARS"]?.append(vaccine)
                } else if vaccineInfo.startWeek <= 312 { // ~4-6 years
                    vaccinesByTimeframe["4-6 YEARS"]?.append(vaccine)
                } else {
                    vaccinesByTimeframe["11-12 YEARS"]?.append(vaccine)
                }
            } else {
                // If we don't have info, put it in a default group
                let defaultTimeframe = "OTHER"
                if vaccinesByTimeframe[defaultTimeframe] == nil {
                    vaccinesByTimeframe[defaultTimeframe] = []
                }
                vaccinesByTimeframe[defaultTimeframe]?.append(vaccine)
            }
        }
        
        // Convert to array and filter out empty sections
        organizedVaccines = vaccinesByTimeframe.compactMap { key, vaccines in
            if !vaccines.isEmpty {
                return (timeframe: key, vaccines: vaccines)
            }
            return nil
        }.sorted { lhs, rhs in
            // Define order of timeframes
            let order: [String: Int] = [
                "BIRTH": 0,
                "6 WEEKS": 1,
                "10 WEEKS": 2,
                "14 WEEKS": 3,
                "6 MONTHS": 4,
                "9 MONTHS": 5,
                "12 MONTHS": 6,
                "15 MONTHS": 7,
                "18 MONTHS": 8,
                "2 YEARS": 9,
                "4-6 YEARS": 10,
                "11-12 YEARS": 11,
                "OTHER": 12
            ]
            
            return (order[lhs.timeframe] ?? 99) < (order[rhs.timeframe] ?? 99)
        }
    }
    
    private func updateEmptyState(message: String) {
        if administeredVaccines.isEmpty {
            emptyStateLabel.text = message
            emptyStateLabel.isHidden = false
            tableView.isHidden = true
        } else {
            emptyStateLabel.isHidden = true
            tableView.isHidden = false
        }
    }
    
    @objc private func refreshVaccines() {
        loadVaccines()
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return organizedVaccines.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return organizedVaccines[section].vaccines.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemGroupedBackground
        
        // Timeframe label
        let timeframeLabel = UILabel()
        timeframeLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        timeframeLabel.textColor = .secondaryLabel
        timeframeLabel.text = organizedVaccines[section].timeframe
        timeframeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(timeframeLabel)
        
        NSLayoutConstraint.activate([
            timeframeLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            timeframeLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            timeframeLabel.trailingAnchor.constraint(lessThanOrEqualTo: headerView.trailingAnchor, constant: -16)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40 // Reduced height since we only have one line of text now
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AdministeredVaccineCell", for: indexPath) as? AdministeredVaccineCell else {
            return UITableViewCell()
        }
        
        let section = organizedVaccines[indexPath.section]
        let administeredVaccine = section.vaccines[indexPath.row]
        
        // Try different formats for the vaccine ID to match with the cached vaccines
        let vaccineId = administeredVaccine.vaccineId.uuidString
        let vaccineInfo = vaccines[vaccineId]
        
        // Configure cell with menu action handler
        cell.configure(with: administeredVaccine, vaccine: vaccineInfo)
        cell.delegate = self
        
        return cell
    }
    
    // MARK: - Vaccination Records PDF Generation and Download
    
    @objc private func downloadVaccinationRecords() {
        // Check if we have vaccines to generate a record
        guard !administeredVaccines.isEmpty else {
            let alert = UIAlertController(
                title: "No Records",
                message: "There are no vaccination records available to download.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Show loading indicator
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        // Fetch data and generate PDF
        Task {
            do {
                let babyParentData = try await fetchBabyAndParentData()
                await MainActor.run {
                    generateAndSharePDF(with: babyParentData)
                    activityIndicator.stopAnimating()
                    view.isUserInteractionEnabled = true
                }
            } catch {
                await MainActor.run {
                    activityIndicator.stopAnimating()
                    view.isUserInteractionEnabled = true
                    
                    // If there's no baby selected, fall back to local data
                    if (error as NSError).domain == "VacciAlertError" &&
                       ((error as NSError).code == 2 || (error as NSError).code == 3) {
                        // Try to fetch baby data directly from Supabase
                        Task {
                            do {
                                let baby = try await fetchFirstConnectedBaby()
                                
                                let fakeBabyData = BabyData(
                                    id: baby.babyID.uuidString,
                                    name: baby.name,
                                    dateOfBirth: baby.dateOfBirth,
                                    gender: baby.gender == .male ? "male" : "female"
                                )
                                
                                let fakeParentData = ParentData(
                                    id: UUID().uuidString,
                                    name: UserDefaults.standard.string(forKey: "parentName") ?? "Parent",
                                    relation: "parent"
                                )
                                
                                await MainActor.run {
                                    generateAndSharePDF(with: (fakeBabyData, fakeParentData))
                                }
                            } catch {
                                print("❌ Error fetching baby: \(error)")
                                // Create generic data as fallback
                                let fakeBabyData = BabyData(
                                    id: UUID().uuidString,
                                    name: "Baby",
                                    dateOfBirth: "01/01/2023",
                                    gender: "unknown"
                                )
                                
                                let fakeParentData = ParentData(
                                    id: UUID().uuidString,
                                    name: UserDefaults.standard.string(forKey: "parentName") ?? "Parent",
                                    relation: "parent"
                                )
                                
                                await MainActor.run {
                                    generateAndSharePDF(with: (fakeBabyData, fakeParentData))
                                }
                            }
                            return
                        }
                    }
                    
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Could not fetch data: \(error.localizedDescription)",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    present(alert, animated: true)
                }
            }
        }
    }
    
    // Fetch baby and parent data from Supabase
    private func fetchBabyAndParentData() async throws -> (baby: BabyData, parent: ParentData) {
        guard let client = (UIApplication.shared.delegate as? AppDelegate)?.supabase ??
                          (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.supabase else {
            throw NSError(domain: "VacciAlertError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Supabase client not available"])
        }
        
        // Try to get current baby ID from UserDefaults
        let babyId: String
        if let selectedBabyId = UserDefaults.standard.string(forKey: "selectedBabyId") {
            babyId = selectedBabyId
        } else {
            // If no baby is directly selected, try to get the parent UUID
            let parentUUID: String
            
            // First try to get parent UUID from UserDefaults
            if let storedParentUUID = UserDefaults.standard.string(forKey: "parentUUID") ??
                                     UserDefaults.standard.string(forKey: "currentUserId") {
                parentUUID = storedParentUUID
            }
            // If not in UserDefaults, try to get from Supabase session
            else if let session = try? client.auth.session {
                // Get user ID as string
                parentUUID = session.user.id.uuidString
            }
            // If all else fails, throw an error
            else {
                throw NSError(domain: "VacciAlertError", code: 2,
                             userInfo: [NSLocalizedDescriptionKey: "No parent or baby found"])
            }
            
            // Fetch the baby associated with this parent (since there's a maximum of 1 baby per parent)
            let babyResponse = try await client
                .from("baby")
                .select()
                .eq("user_id", value: parentUUID)
                .limit(1)
                .execute()
            
            if let babyData = try? JSONDecoder().decode([BabyData].self, from: babyResponse.data),
               let firstBaby = babyData.first {
                // Save the baby UID for future use
                UserDefaults.standard.set(firstBaby.id, forKey: "selectedBabyId")
                babyId = firstBaby.id
            } else {
                throw NSError(domain: "VacciAlertError", code: 3,
                             userInfo: [NSLocalizedDescriptionKey: "Could not find baby for the current parent"])
            }
        }
        
        // Fetch baby data by ID now that we have a valid baby ID
        let babyResponse = try await client
            .from("baby")
            .select()
            .eq("uid", value: babyId)
            .single()
            .execute()
        
        let babyData = try JSONDecoder().decode(BabyData.self, from: babyResponse.data)
        
        // First try to get parent name from UserDefaults
        let parentName = UserDefaults.standard.string(forKey: "parentName")
        if let parentName = parentName {
            // Create parent data with UserDefaults name
            let parentData = ParentData(
                id: UUID().uuidString,
                name: parentName,
                relation: "parent"
            )
            return (babyData, parentData)
        }
        
        // If no parent name in UserDefaults, try to fetch from Supabase
        let parentResponse = try await client
            .from("parents")
            .select()
            .eq("baby_uid", value: babyId)
            .single()
            .execute()
        
        if let parentData = try? JSONDecoder().decode(ParentData.self, from: parentResponse.data) {
            // Save parent name to UserDefaults for future use
            UserDefaults.standard.set(parentData.name, forKey: "parentName")
            return (babyData, parentData)
        }
        
        // If we couldn't get parent data from Supabase, create a default one
        let defaultParentData = ParentData(
            id: UUID().uuidString,
            name: "Parent",
            relation: "parent"
        )
        
        return (babyData, defaultParentData)
    }
    
    // Data structures for Supabase responses
    struct BabyData: Codable {
        let id: String
        let name: String
        let dateOfBirth: String
        let gender: String
        
        enum CodingKeys: String, CodingKey {
            case id = "uid"
            case name
            case dateOfBirth = "dob"
            case gender
        }
    }
    
    struct ParentData: Codable {
        let id: String
        let name: String
        let relation: String
        
        enum CodingKeys: String, CodingKey {
            case id = "uid"
            case name
            case relation = "relationship"
        }
    }
    
    // Generate PDF with vaccination records in a card format
    private func generateAndSharePDF(with data: (baby: BabyData, parent: ParentData)? = nil) {
        // Create PDF renderer with A4 portrait size
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11.0 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        // Define colors to be used consistently across all pages
        let backgroundColor = UIColor.white // Changed to white
        let primaryTextColor = UIColor(red: 0.0, green: 0.32, blue: 0.6, alpha: 1.0) // Darker blue
        let secondaryTextColor = UIColor(red: 0.2, green: 0.47, blue: 0.7, alpha: 1.0) // Medium blue
        let tableHeaderColor = UIColor(red: 0.35, green: 0.6, blue: 0.8, alpha: 1.0) // Sky blue for header on white
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        // Generate PDF data
        let pdfData = renderer.pdfData { context in
            context.beginPage()
            
            // Draw background
            backgroundColor.setFill()
            UIRectFill(pageRect)
            
            // Add Faby watermark
            drawFabyWatermark(context: context, pageWidth: pageWidth, pageHeight: pageHeight)
            
            // Draw dotted border
            let borderRect = CGRect(x: 60, y: 60, width: pageWidth - 120, height: pageHeight - 120)
            let borderPath = UIBezierPath(rect: borderRect)
            borderPath.lineWidth = 1.0
            
            // Create a dotted pattern
            context.cgContext.setLineDash(phase: 0, lengths: [3, 3])
            context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
            context.cgContext.addPath(borderPath.cgPath)
            context.cgContext.strokePath()
            
            // Reset line dash
            context.cgContext.setLineDash(phase: 0, lengths: [])
            
            // Draw baby icon
            if let babyImage = UIImage(systemName: "face.smiling.fill") {
                let iconSize: CGFloat = 80
                let iconRect = CGRect(
                    x: pageWidth - 150,
                    y: 100,
                    width: iconSize,
                    height: iconSize
                )
                
                // Create a circular background
                context.cgContext.setFillColor(UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0).cgColor)
                context.cgContext.fillEllipse(in: iconRect)
                
                // Draw the icon
                babyImage.withTintColor(primaryTextColor).draw(in: iconRect.insetBy(dx: 15, dy: 15))
            }
            
            // Add title
            let titleText = "VACCINATION"
            let titleFont = UIFont.systemFont(ofSize: 36, weight: .bold)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: primaryTextColor
            ]
            
            titleText.draw(at: CGPoint(x: 100, y: 100), withAttributes: titleAttributes)
            
            // Add subtitle
            let subtitleText = "RECORD"
            let subtitleFont = UIFont.systemFont(ofSize: 36, weight: .bold)
            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: subtitleFont,
                .foregroundColor: primaryTextColor
            ]
            
            subtitleText.draw(at: CGPoint(x: 100, y: 150), withAttributes: subtitleAttributes)
            
            // Add baby information
            var currentY: CGFloat = 250
            
            // Name
            let babyName = data?.baby.name ?? "Child's Name"
            drawInfoField(label: "Name", value: babyName, y: currentY, primaryColor: primaryTextColor, secondaryColor: secondaryTextColor)
            currentY += 50
            
            // Date of Birth
            let birthDateString: String
            if let dob = data?.baby.dateOfBirth {
                // First try parsing as "ddMMyyyy"
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "ddMMyyyy"
                if let date = dateFormatter.date(from: dob) {
                    dateFormatter.dateStyle = .long
                    birthDateString = dateFormatter.string(from: date)
                } else {
                    // If that fails, try parsing as ISO format
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    if let date = dateFormatter.date(from: dob) {
                        dateFormatter.dateStyle = .long
                        birthDateString = dateFormatter.string(from: date)
                    } else {
                        // If all parsing fails, use the raw string
                        birthDateString = dob
                    }
                }
            } else {
                birthDateString = "Date of Birth"
            }
            drawInfoField(label: "Date of Birth", value: birthDateString, y: currentY, primaryColor: primaryTextColor, secondaryColor: secondaryTextColor)
            currentY += 50
            
            // Gender
            let genderString: String
            if let gender = data?.baby.gender.lowercased() {
                genderString = gender == "male" ? "Male" : "Female"
            } else {
                genderString = "Gender"
            }
            drawInfoField(label: "Gender", value: genderString, y: currentY, primaryColor: primaryTextColor, secondaryColor: secondaryTextColor)
            currentY += 50
            
            // Parent
            let parentName = data?.parent.name ?? "Parent"
            drawInfoField(label: "Parent", value: parentName, y: currentY, primaryColor: primaryTextColor, secondaryColor: secondaryTextColor)
            currentY += 70
            
            // Draw vaccination table
            drawVaccinationTable(context: context, startY: currentY, pageWidth: pageWidth, pageHeight: pageHeight,
                               backgroundColor: backgroundColor, headerColor: tableHeaderColor,
                               textColor: primaryTextColor)
        }
        
        // Create a temporary file URL to store the PDF
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let fileName = data?.baby.name ?? "Baby"
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent("\(fileName)_Vaccination_Record.pdf")
        
        // Write PDF data to file
        do {
            try pdfData.write(to: temporaryFileURL)
            
            // Share the PDF file
            let activityViewController = UIActivityViewController(
                activityItems: [temporaryFileURL],
                applicationActivities: nil
            )
            
            // Configure the activity view controller
            activityViewController.excludedActivityTypes = [
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToVimeo,
                UIActivity.ActivityType.postToWeibo,
                UIActivity.ActivityType.saveToCameraRoll
            ]
            
            // For iPad, set the popover presentation controller
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.barButtonItem = navigationItem.rightBarButtonItem
            }
            
            // Present the activity view controller
            present(activityViewController, animated: true)
        } catch {
            print("Error writing PDF: \(error)")
            
            let alert = UIAlertController(
                title: "Error",
                message: "Could not generate vaccination record. Please try again.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    // Helper method to draw an information field with label and value
    private func drawInfoField(label: String, value: String, y: CGFloat, primaryColor: UIColor, secondaryColor: UIColor) {
        let labelFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: labelFont,
            .foregroundColor: primaryColor
        ]
        
        let valueFont = UIFont.systemFont(ofSize: 20, weight: .regular)
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: valueFont,
            .foregroundColor: secondaryColor
        ]
        
        // Draw label
        label.draw(at: CGPoint(x: 100, y: y), withAttributes: labelAttributes)
        
        // Draw value
        value.draw(at: CGPoint(x: 220, y: y), withAttributes: valueAttributes)
    }
    
    // Helper function to draw the Faby watermark
    private func drawFabyWatermark(context: UIGraphicsPDFRendererContext, pageWidth: CGFloat, pageHeight: CGFloat) {
        let watermarkText = "Faby"
        let watermarkFont = UIFont.systemFont(ofSize: 150, weight: .bold)
        // Light gray watermark, subtle on white background
        let watermarkAttributes: [NSAttributedString.Key: Any] = [
            .font: watermarkFont,
            .foregroundColor: UIColor(white: 0.85, alpha: 0.2) 
        ]
    
        let watermarkSize = (watermarkText as NSString).size(withAttributes: watermarkAttributes)
        let watermarkPoint = CGPoint(
            x: (pageWidth - watermarkSize.width) / 2,
            y: (pageHeight - watermarkSize.height) / 2
        )
    
        context.cgContext.saveGState()
        context.cgContext.translateBy(x: watermarkPoint.x + watermarkSize.width / 2,
                                   y: watermarkPoint.y + watermarkSize.height / 2)
        context.cgContext.rotate(by: -CGFloat.pi / 4) // Rotate -45 degrees
        context.cgContext.translateBy(x: -(watermarkPoint.x + watermarkSize.width / 2),
                                   y: -(watermarkPoint.y + watermarkSize.height / 2))
        watermarkText.draw(at: watermarkPoint, withAttributes: watermarkAttributes)
        context.cgContext.restoreGState()
    }
    
    // Helper method to draw the vaccination table
    private func drawVaccinationTable(context: UIGraphicsPDFRendererContext, startY: CGFloat, pageWidth: CGFloat, pageHeight: CGFloat,
                                     backgroundColor: UIColor, headerColor: UIColor, textColor: UIColor) {
        let tableWidth = pageWidth - 200
        let tableX = 100.0
        var currentY = startY
        
        // Organize vaccines by timeframe
        var vaccinesByTimeframe: [String: [VaccineAdministered]] = [
            "BIRTH": [],
            "6 WEEKS": [],
            "10 WEEKS": [],
            "14 WEEKS": [],
            "6 MONTHS": [],
            "9 MONTHS": [],
            "12 MONTHS": [],
            "15 MONTHS": [],
            "18 MONTHS": [],
            "2 YEARS": [],
            "4-6 YEARS": [],
            "11-12 YEARS": []
        ]
        
        // Group vaccines by timeframe
        for administeredVaccine in administeredVaccines {
            let vaccineId = administeredVaccine.vaccineId.uuidString
            if let vaccineInfo = vaccines[vaccineId] {
                // Use vaccine info to determine timeframe
                if vaccineInfo.startWeek == 0 {
                    vaccinesByTimeframe["BIRTH"]?.append(administeredVaccine)
                } else if vaccineInfo.startWeek <= 6 {
                    vaccinesByTimeframe["6 WEEKS"]?.append(administeredVaccine)
                } else if vaccineInfo.startWeek <= 10 {
                    vaccinesByTimeframe["10 WEEKS"]?.append(administeredVaccine)
                } else if vaccineInfo.startWeek <= 14 {
                    vaccinesByTimeframe["14 WEEKS"]?.append(administeredVaccine)
                } else if vaccineInfo.startWeek <= 26 { // ~6 months
                    vaccinesByTimeframe["6 MONTHS"]?.append(administeredVaccine)
                } else if vaccineInfo.startWeek <= 39 { // ~9 months
                    vaccinesByTimeframe["9 MONTHS"]?.append(administeredVaccine)
                } else if vaccineInfo.startWeek <= 52 { // ~12 months
                    vaccinesByTimeframe["12 MONTHS"]?.append(administeredVaccine)
                } else if vaccineInfo.startWeek <= 65 { // ~15 months
                    vaccinesByTimeframe["15 MONTHS"]?.append(administeredVaccine)
                } else if vaccineInfo.startWeek <= 78 { // ~18 months
                    vaccinesByTimeframe["18 MONTHS"]?.append(administeredVaccine)
                } else if vaccineInfo.startWeek <= 104 { // ~2 years
                    vaccinesByTimeframe["2 YEARS"]?.append(administeredVaccine)
                } else if vaccineInfo.startWeek <= 312 { // ~4-6 years
                    vaccinesByTimeframe["4-6 YEARS"]?.append(administeredVaccine)
                } else {
                    vaccinesByTimeframe["11-12 YEARS"]?.append(administeredVaccine)
                }
            }
        }
        
        // Sort timeframes and filter out empty ones
        let sortedTimeframes = vaccinesByTimeframe.filter { !$0.value.isEmpty }
            .sorted { first, second in
                let order: [String: Int] = [
                    "BIRTH": 0,
                    "6 WEEKS": 1,
                    "10 WEEKS": 2,
                    "14 WEEKS": 3,
                    "6 MONTHS": 4,
                    "9 MONTHS": 5,
                    "12 MONTHS": 6,
                    "15 MONTHS": 7,
                    "18 MONTHS": 8,
                    "2 YEARS": 9,
                    "4-6 YEARS": 10,
                    "11-12 YEARS": 11
                ]
                return (order[first.key] ?? 99) < (order[second.key] ?? 99)
            }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        // Draw sections for each timeframe
        for (timeframe, timeframeVaccines) in sortedTimeframes {
            // Draw timeframe header
            let timeframeFont = UIFont.systemFont(ofSize: 18, weight: .bold)
            let timeframeAttributes: [NSAttributedString.Key: Any] = [
                .font: timeframeFont,
                .foregroundColor: textColor
            ]
            
            timeframe.draw(at: CGPoint(x: tableX, y: currentY), withAttributes: timeframeAttributes)
            currentY += 30
            
            // Draw table header
            let headerHeight = 40.0
            let headerRect = CGRect(x: tableX, y: currentY, width: tableWidth, height: headerHeight)
            headerColor.setFill()
            UIRectFill(headerRect)
            
            // Draw header text
            let nameHeaderWidth = tableWidth * 0.6
            
            let headerFont = UIFont.systemFont(ofSize: 16, weight: .bold)
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: headerFont,
                .foregroundColor: UIColor.white
            ]
            
            "Vaccine Name".draw(at: CGPoint(x: tableX + 10, y: currentY + 12), withAttributes: headerAttributes)
            "Administered Date".draw(at: CGPoint(x: tableX + nameHeaderWidth + 10, y: currentY + 12), withAttributes: headerAttributes)
            
            // Draw header divider
            context.cgContext.setStrokeColor(UIColor.white.cgColor)
            context.cgContext.setLineWidth(1.0)
            context.cgContext.move(to: CGPoint(x: tableX + nameHeaderWidth, y: currentY))
            context.cgContext.addLine(to: CGPoint(x: tableX + nameHeaderWidth, y: currentY + headerHeight))
            context.cgContext.strokePath()
            
            currentY += headerHeight
            
            // Draw rows for this timeframe
            let rowHeight = 35.0
            let rowFont = UIFont.systemFont(ofSize: 14)
            let rowAttributes: [NSAttributedString.Key: Any] = [
                .font: rowFont,
                .foregroundColor: textColor
            ]
            
            for administeredVaccine in timeframeVaccines {
                // Draw row background
                let rowRect = CGRect(x: tableX, y: currentY, width: tableWidth, height: rowHeight)
                backgroundColor.setFill()
                UIRectFill(rowRect)
                
                // Draw border
                context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
                context.cgContext.setLineWidth(0.5)
                context.cgContext.stroke(rowRect)
                
                // Draw vertical divider
                context.cgContext.move(to: CGPoint(x: tableX + nameHeaderWidth, y: currentY))
                context.cgContext.addLine(to: CGPoint(x: tableX + nameHeaderWidth, y: currentY + rowHeight))
                context.cgContext.strokePath()
                
                // Get vaccine name from cache
                let vaccineId = administeredVaccine.vaccineId.uuidString
                let vaccineName = vaccines[vaccineId]?.name ?? "Unknown Vaccine"
                
                // Draw vaccine name
                vaccineName.draw(at: CGPoint(x: tableX + 10, y: currentY + 12), withAttributes: rowAttributes)
                
                // Draw administered date
                let dateString = dateFormatter.string(from: administeredVaccine.administeredDate)
                dateString.draw(at: CGPoint(x: tableX + nameHeaderWidth + 10, y: currentY + 12), withAttributes: rowAttributes)
                
                currentY += rowHeight
                
                // Check if we need a new page
                if currentY > context.pdfContextBounds.height - 100 {
                    context.beginPage()
                    
                    // Draw consistent background color on new page
                    backgroundColor.setFill()
                    UIRectFill(context.pdfContextBounds)

                    // Add Faby watermark to new page
                    drawFabyWatermark(context: context, pageWidth: pageWidth, pageHeight: pageHeight)
                    
                    // Draw dotted border on new page
                    let borderRect = CGRect(x: 60, y: 60,
                                          width: context.pdfContextBounds.width - 120,
                                          height: context.pdfContextBounds.height - 120)
                    let borderPath = UIBezierPath(rect: borderRect)
                    borderPath.lineWidth = 1.0
                    
                    // Create a dotted pattern
                    context.cgContext.setLineDash(phase: 0, lengths: [3, 3])
                    context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
                    context.cgContext.addPath(borderPath.cgPath)
                    context.cgContext.strokePath()
                    
                    // Reset line dash
                    context.cgContext.setLineDash(phase: 0, lengths: [])
                    
                    currentY = 60
                    
                    // Continue with timeframe header on new page
                    timeframe.draw(at: CGPoint(x: tableX, y: currentY), withAttributes: timeframeAttributes)
                    currentY += 30
                    
                    // Redraw the header on the new page
                    let headerRect = CGRect(x: tableX, y: currentY, width: tableWidth, height: headerHeight)
                    headerColor.setFill()
                    UIRectFill(headerRect)
                    
                    "Vaccine Name".draw(at: CGPoint(x: tableX + 10, y: currentY + 12), withAttributes: headerAttributes)
                    "Administered Date".draw(at: CGPoint(x: tableX + nameHeaderWidth + 10, y: currentY + 12), withAttributes: headerAttributes)
                    
                    context.cgContext.setStrokeColor(UIColor.white.cgColor)
                    context.cgContext.setLineWidth(1.0)
                    context.cgContext.move(to: CGPoint(x: tableX + nameHeaderWidth, y: currentY))
                    context.cgContext.addLine(to: CGPoint(x: tableX + nameHeaderWidth, y: currentY + headerHeight))
                    context.cgContext.strokePath()
                    
                    currentY += headerHeight
                }
            }
            
            // Add space between timeframe sections
            currentY += 30
            
            // Check if we need a new page before starting next timeframe
            if currentY > context.pdfContextBounds.height - 130 {
                context.beginPage()
                currentY = 60
                
                // Draw consistent background color on new page
                backgroundColor.setFill()
                UIRectFill(context.pdfContextBounds)

                // Add Faby watermark to new page
                drawFabyWatermark(context: context, pageWidth: pageWidth, pageHeight: pageHeight)
                
                // Draw dotted border on new page
                let borderRect = CGRect(x: 60, y: 60,
                                      width: context.pdfContextBounds.width - 120,
                                      height: context.pdfContextBounds.height - 120)
                let borderPath = UIBezierPath(rect: borderRect)
                borderPath.lineWidth = 1.0
                
                // Create a dotted pattern
                context.cgContext.setLineDash(phase: 0, lengths: [3, 3])
                context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
                context.cgContext.addPath(borderPath.cgPath)
                context.cgContext.strokePath()
                
                // Reset line dash
                context.cgContext.setLineDash(phase: 0, lengths: [])
            }
        }
    }
    
    // MARK: - Baby Data Fetching
    // Using shared methods from BabyDataModels.swift
    
    // MARK: - Date Change Functionality
    
    /// Shows iOS-native date picker when user wants to change the administered date
    func showDateChangeOptions(for vaccine: VaccineAdministered) {
        // Create alert controller with action sheet style
        let alertController = UIAlertController(title: "", message: "Update administered date", preferredStyle: .actionSheet)
        
        // Create custom view for date picker with sufficient height
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: alertController.view.bounds.width - 16, height: 380))
        
        // Create and configure date picker using iOS-native inline style
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline  // Modern iOS inline calendar style
        datePicker.date = vaccine.administeredDate
        
        // Allow past dates for administered vaccines but limit future dates
        datePicker.maximumDate = Date()  // Can't administer vaccines in the future
        
        // Configure datePicker to properly fit in the view
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        customView.addSubview(datePicker)
        
        // Add constraints to ensure datePicker is properly sized and positioned
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: customView.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: customView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: customView.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: customView.bottomAnchor)
        ])
        
        // Add custom view to alert
        alertController.view.addSubview(customView)
        
        // Adjust alert height to accommodate date picker and prevent cut-off dates
        let heightConstraint = NSLayoutConstraint(
            item: alertController.view!,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 580 // Increased height to ensure all dates are visible
        )
        alertController.view.addConstraint(heightConstraint)
        
        // Add actions
        let updateAction = UIAlertAction(title: "Update", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // Start loading state
            self.activityIndicator.startAnimating()
            
            // Immediately update the local data model before server update
            let newDate = datePicker.date
            
            // Find the vaccine in our local array and update its date
            for (sectionIndex, section) in self.organizedVaccines.enumerated() {
                if let vaccineIndex = section.vaccines.firstIndex(where: { $0.id == vaccine.id }) {
                    // Update the vaccine's date locally
                    self.organizedVaccines[sectionIndex].vaccines[vaccineIndex].administeredDate = newDate
                    self.organizedVaccines[sectionIndex].vaccines[vaccineIndex].hasDate = true
                    
                    // Get the indexPath for this vaccine
                    let indexPath = IndexPath(row: vaccineIndex, section: sectionIndex)
                    
                    // Update the cell if it's visible
                    if let cell = self.tableView.cellForRow(at: indexPath) as? AdministeredVaccineCell {
                        cell.updateDate(newDate: newDate)
                    }
                    
                    // Also update in the main array
                    if let mainIndex = self.administeredVaccines.firstIndex(where: { $0.id == vaccine.id }) {
                        self.administeredVaccines[mainIndex].administeredDate = newDate
                        self.administeredVaccines[mainIndex].hasDate = true
                    }
                }
            }
            
            // Update the database
            Task {
                do {
                    try await SupabaseVaccineManager.shared.updateAdministeredVaccineDate(
                        vaccineId: vaccine.id.uuidString,
                        newDate: newDate
                    )
                    
                    await MainActor.run {
                        self.activityIndicator.stopAnimating()
                        self.showToast(message: "Date updated successfully")
                    }
                } catch {
                    print("Failed to update date: \(error)")
                    
                    await MainActor.run {
                        self.activityIndicator.stopAnimating()
                        self.showToast(message: "Failed to update date. Please try again.")
                        self.loadVaccines() // Reload to reset changes
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(updateAction)
        alertController.addAction(cancelAction)
        
        // For iPad support
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alertController, animated: true)
    }
    
    // MARK: - AdministeredVaccineCellDelegate Implementation
    
    /// Handler for when a user taps on the date change button for a vaccine
    func showOptionsForVaccine(_ vaccine: VaccineAdministered) {
        showDateChangeOptions(for: vaccine)
    }
    
    // MARK: - Feedback Methods
    
    /// Shows a toast message with feedback about the operation
    func showToast(message: String) {
        let toastContainer = UIView()
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastContainer.layer.cornerRadius = 16
        toastContainer.clipsToBounds = true
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let toastLabel = UILabel()
        toastLabel.textColor = .white
        toastLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.numberOfLines = 0
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        toastContainer.addSubview(toastLabel)
        view.addSubview(toastContainer)
        
        // Set constraints
        NSLayoutConstraint.activate([
            toastLabel.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: 12),
            toastLabel.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 16),
            toastLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -16),
            toastLabel.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -12),
            
            toastContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            toastContainer.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            toastContainer.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
        
        // Animate in
        toastContainer.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            toastContainer.alpha = 1
        }, completion: { _ in
            // Animate out after delay
            UIView.animate(withDuration: 0.2, delay: 2.0, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0
            }, completion: { _ in
                toastContainer.removeFromSuperview()
            })
        })
    }
}

// MARK: - Vaccine Cell Class
class AdministeredVaccineCell: UITableViewCell {
    // Card container view - maintains the iOS native look
    private let cardView = UIView()
    
    // Content labels
    private let nameLabel = UILabel()
    private let dateLabel = UILabel()
    
    // Icon view
    private let iconImageView = UIImageView()
    
    // Menu button
    private let menuButton = UIButton(type: .system)
    
    // Store the administered vaccine for menu actions
    var vaccine: VaccineAdministered?
    
    // Delegate to handle menu actions
    weak var delegate: SavedVaccineViewController?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Configure cell background
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = .clear
        
        // Configure card view
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        
        // Configure icon image view
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemBlue
        iconImageView.image = UIImage(systemName: "syringe.fill")
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(iconImageView)
        
        // Configure name label
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 0
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameLabel)
        
        // Configure date label
        dateLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        dateLabel.textColor = .secondaryLabel
        dateLabel.numberOfLines = 1
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(dateLabel)
        
        // Configure date change button with iOS-native calendar icon
        let dateChangeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        menuButton.setImage(UIImage(systemName: "calendar.badge.clock", withConfiguration: dateChangeConfig), for: .normal)
        menuButton.tintColor = .systemBlue
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        cardView.addSubview(menuButton)
        
        // Set constraints for all subviews
        NSLayoutConstraint.activate([
            // Card view constraints
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // Icon image view constraints
            iconImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Name label constraints
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: menuButton.leadingAnchor, constant: -12),
            
            // Date label constraints
            dateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            // Menu button constraints
            menuButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            menuButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            menuButton.widthAnchor.constraint(equalToConstant: 32),
            menuButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    @objc private func showMenu() {
        guard let vaccine = vaccine, let delegate = delegate else { return }
        
        // Trigger the date change options in the view controller
        delegate.showOptionsForVaccine(vaccine)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        dateLabel.text = nil
        vaccine = nil
    }
    
    func configure(with administeredVaccine: VaccineAdministered, vaccine: Vaccine?) {
        // Store the vaccine for menu actions
        self.vaccine = administeredVaccine
        
        // Set up vaccine name
        nameLabel.text = vaccine?.name ?? "Unknown Vaccine"
        
        // Format the date with proper timezone handling
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = TimeZone.current
        
        // Check if the vaccine has a date
        if administeredVaccine.hasDate {
            // Use the actual administered date from the database
            let dateString = dateFormatter.string(from: administeredVaccine.administeredDate)
            dateLabel.text = "Administered on \(dateString)"
        } else {
            // No date was selected
            dateLabel.text = "No date selected"
            dateLabel.textColor = .systemOrange
        }
        
        // Always use syringe icon with systemBlue color
        iconImageView.image = UIImage(systemName: "syringe.fill")
        iconImageView.tintColor = .systemBlue
    }
    
    /// Updates the displayed date in the cell without requiring a full reload
    func updateDate(newDate: Date) {
        // Update the stored vaccine object
        if var vaccine = self.vaccine {
            vaccine.administeredDate = newDate
            vaccine.hasDate = true
            self.vaccine = vaccine
        }
        
        // Update the displayed date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateLabel.text = "Administered on \(dateFormatter.string(from: newDate))"
        dateLabel.textColor = .secondaryLabel
        
        // Add a subtle animation to highlight the update
        UIView.animate(withDuration: 0.3) {
            self.dateLabel.alpha = 0.3
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.dateLabel.alpha = 1.0
            }
        }
    }
}

// MARK: - Date Picker View Controller
class DatePickerViewController: UIViewController {
    
    // Date picker to select new date
    private let datePicker = UIDatePicker()
    
    // Callback when date is selected
    var dateSelected: ((Date) -> Void)?
    
    // Initial date to show
    var initialDate: Date = Date()
    
    // Maximum date (defaults to today)
    var maximumDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Container view for better styling
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "Change Administration Date"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Date picker setup
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.date = initialDate
        datePicker.maximumDate = maximumDate
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(datePicker)
        
        // Done button
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", style: .body, state: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        doneButton.setTitleColor(.systemBlue, for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(doneButton)
        
        // Cancel button
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", style: .body, state: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(cancelButton)
        
        // Separator line
        let separatorView = UIView()
        separatorView.backgroundColor = .systemGray5
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            separatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            datePicker.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            datePicker.heightAnchor.constraint(equalToConstant: 216),
            
            doneButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 16),
            doneButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            cancelButton.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 16),
            cancelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func doneButtonTapped() {
        dateSelected?(datePicker.date)
        dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
}

// Add extension for button styling
extension UIButton {
    func setTitle(_ title: String, style: UIFont.TextStyle, state: UIControl.State) {
        setTitle(title, for: state)
        titleLabel?.font = UIFont.preferredFont(forTextStyle: style)
    }
}

// MARK: - Model Extensions
extension Vaccine {
    var targetAgeRange: String? {
        let minMonth = startWeek / 4
        let maxMonth = endWeek / 4
        return "\(minMonth)-\(maxMonth) months"
    }
}

// MARK: - UIAlertController Extension for Date Picker
extension UIAlertController {
    /// Adds a date picker to an alert controller
    ///
    /// - Parameters:
    ///   - mode: The mode of the date picker (e.g., date, time, dateAndTime)
    ///   - date: The initial date to display
    ///   - minimumDate: The minimum selectable date (or nil for no minimum)
    ///   - maximumDate: The maximum selectable date (or nil for no maximum)
    ///   - action: The action to perform when a date is selected
    func addDatePicker(
        mode: UIDatePicker.Mode, date: Date, minimumDate: Date? = nil, maximumDate: Date? = nil, action: @escaping (Date) -> Void) {
        // Create a container view for the date picker
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create date picker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = mode
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.date = date
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        // Add to container
        containerView.addSubview(datePicker)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: containerView.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            datePicker.heightAnchor.constraint(equalToConstant: 216) // Standard height for date picker
        ])
        
        // Set up alert view
        self.view.addSubview(containerView)
        
        // Position container view to be centered and sized correctly
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50),
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        // Add a "Done" button
        self.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            action(datePicker.date)
        }))
    }
}
