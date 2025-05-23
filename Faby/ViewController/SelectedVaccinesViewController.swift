import UIKit
import Foundation
import PDFKit

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
            dateLabel.text = "Adminstered on: \(dateFormatter.string(from: selectedDate))"
            dateLabel.textColor = .systemGreen
        } else {
            dateLabel.text = "Tap to add administration date"
            dateLabel.textColor = .systemBlue
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
        
        // Add tap gesture to all cards, so user can add or update date
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(vaccineCardTapped(_:)))
            cardView.addGestureRecognizer(tapGesture)
            cardView.isUserInteractionEnabled = true
        
        return cardView
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func printButtonTapped() {
        // Show loading indicator
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = view.center
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        
        // Disable the print button while generating PDF
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        Task {
            do {
                // Try to fetch baby data
                let baby = try await fetchFirstConnectedBaby()
                
                // Try to get parent name from different sources
                var parentName: String?
                
                // First try to get from UserDefaults
                if let storedParentName = UserDefaults.standard.string(forKey: "parentName") {
                    parentName = storedParentName
                } else {
                    // If not in UserDefaults, try to fetch from Supabase
                    if let client = (UIApplication.shared.delegate as? AppDelegate)?.supabase ??
                                  (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.supabase {
                        do {
                            let parentResponse = try await client
                                .from("parents")
                                .select()
                                .eq("baby_uid", value: baby.babyID.uuidString)
                                .single()
                                .execute()
                            
                            if let parentData = try? JSONDecoder().decode(ParentData.self, from: parentResponse.data) {
                                parentName = parentData.name
                                // Save to UserDefaults for future use
                                UserDefaults.standard.set(parentData.name, forKey: "parentName")
                            }
                        } catch {
                            print("❌ Error fetching parent data: \(error)")
                        }
                    }
                }
                
                // If we still don't have a parent name, use a default
                if parentName == nil {
                    parentName = UserDefaults.standard.string(forKey: "parentName") ?? "Parent"
                }
                
                await MainActor.run {
                    generateAndSharePDF(
                        babyName: baby.name,
                        babyDOB: baby.dateOfBirth,
                        babyGender: baby.gender == .male ? "Male" : "Female",
                        parentName: parentName ?? "Parent"
                    )
                    loadingIndicator.removeFromSuperview()
                    navigationItem.rightBarButtonItem?.isEnabled = true
                }
            } catch {
                print("❌ Error fetching baby: \(error)")
                
                await MainActor.run {
                    // Fall back to generic data if we can't fetch baby info
                    generateAndSharePDF()
                    loadingIndicator.removeFromSuperview()
                    navigationItem.rightBarButtonItem?.isEnabled = true
                }
            }
        }
    }
    
    // Add ParentData model to match SavedVaccineViewController
    private struct ParentData: Codable {
        let id: String
        let name: String
        let relation: String
        
        enum CodingKeys: String, CodingKey {
            case id = "uid"
            case name
            case relation = "relationship"
        }
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
        context.cgContext.rotate(by: -CGFloat.pi / 4)
        context.cgContext.translateBy(x: -(watermarkPoint.x + watermarkSize.width / 2),
                                   y: -(watermarkPoint.y + watermarkSize.height / 2))
        watermarkText.draw(at: watermarkPoint, withAttributes: watermarkAttributes)
        context.cgContext.restoreGState()
    }

    private func generateAndSharePDF(babyName: String = "Baby", babyDOB: String = "Unknown", babyGender: String = "Unknown", parentName: String = "Parent") {
        // Create PDF renderer with A4 portrait size
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11.0 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        // Define colors to be used consistently across all pages
        let backgroundColor = UIColor.white // White background
        let primaryTextColor = UIColor(red: 0.0, green: 0.32, blue: 0.6, alpha: 1.0) // Darker blue
        let secondaryTextColor = UIColor(red: 0.2, green: 0.47, blue: 0.7, alpha: 1.0) // Medium blue
        let tableHeaderColor = UIColor(red: 0.35, green: 0.6, blue: 0.8, alpha: 1.0) // Sky blue
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        // Generate PDF data
        let data = renderer.pdfData { context in
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
            drawInfoField(label: "Name", value: babyName, y: currentY, primaryColor: primaryTextColor, secondaryColor: secondaryTextColor)
            currentY += 50
            
            // Date of Birth
            drawInfoField(label: "Date of Birth", value: babyDOB, y: currentY, primaryColor: primaryTextColor, secondaryColor: secondaryTextColor)
            currentY += 50
            
            // Gender
            drawInfoField(label: "Gender", value: babyGender, y: currentY, primaryColor: primaryTextColor, secondaryColor: secondaryTextColor)
            currentY += 50
            
            // Parent
            drawInfoField(label: "Parent", value: parentName, y: currentY, primaryColor: primaryTextColor, secondaryColor: secondaryTextColor)
            currentY += 70
            
            // Draw vaccination table
            drawVaccinationTable(context: context, startY: currentY, pageWidth: pageWidth, pageHeight: pageHeight,
                               backgroundColor: backgroundColor, headerColor: tableHeaderColor,
                               textColor: primaryTextColor)
        }
        
        // Create a temporary file URL to store the PDF
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent("\(babyName)_Vaccination_Record.pdf")
        
        // Write PDF data to file
        do {
            try data.write(to: temporaryFileURL)
            
            // Share the PDF file
            let activityViewController = UIActivityViewController(
                activityItems: [temporaryFileURL],
                applicationActivities: nil
            )
            
            // Configure the activity view controller
            activityViewController.excludedActivityTypes = [
                .assignToContact,
                .postToFlickr,
                .postToVimeo,
                .postToWeibo,
                .saveToCameraRoll
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
    
    // Helper method to draw the vaccination table
    private func drawVaccinationTable(context: UIGraphicsPDFRendererContext, startY: CGFloat, pageWidth: CGFloat, pageHeight: CGFloat,
                                     backgroundColor: UIColor, headerColor: UIColor, textColor: UIColor) {
        let tableWidth = pageWidth - 200
        let tableX = 100.0
        var currentY = startY
        
        // Organize vaccines by timeframe
        let organizedVaccines = organizeVaccinesByTimeframe()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        // Draw a section for each timeframe
        for (timeframe, vaccines) in organizedVaccines {
            // Draw timeframe header
            let timeframeFont = UIFont.systemFont(ofSize: 18, weight: .bold)
            let timeframeAttributes: [NSAttributedString.Key: Any] = [
                .font: timeframeFont,
                .foregroundColor: textColor
            ]
            
            timeframe.uppercased().draw(at: CGPoint(x: tableX, y: currentY), withAttributes: timeframeAttributes)
            currentY += 30
            
            // Draw table header
            let headerHeight = 40.0
            let headerRect = CGRect(x: tableX, y: currentY, width: tableWidth, height: headerHeight)
            headerColor.setFill()
            UIRectFill(headerRect)
            
            // Draw header text
            let nameHeaderWidth = tableWidth * 0.6
            let dateHeaderWidth = tableWidth * 0.4
            
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
            
            // Draw rows
            let rowHeight = 35.0
            let rowFont = UIFont.systemFont(ofSize: 14)
            let rowAttributes: [NSAttributedString.Key: Any] = [
                .font: rowFont,
                .foregroundColor: textColor
            ]
            
            // Draw table rows for each vaccine in this timeframe
            for vaccine in vaccines {
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
                
                // Draw vaccine name
                vaccine.name.draw(at: CGPoint(x: tableX + 10, y: currentY + 12), withAttributes: rowAttributes)
                
                // Draw administered date if available, otherwise "Not scheduled"
                let dateString: String
                if let date = selectedDates[vaccine.name] {
                    dateString = dateFormatter.string(from: date)
                } else {
                    dateString = "Not scheduled"
                }
                
                dateString.draw(at: CGPoint(x: tableX + nameHeaderWidth + 10, y: currentY + 12), withAttributes: rowAttributes)
                
                currentY += rowHeight
                
                // Check if we need a new page
                if currentY > context.pdfContextBounds.height - 100 {
                    context.beginPage()
                    
                    // Draw consistent background color on new page
                    backgroundColor.setFill()
                    UIRectFill(context.pdfContextBounds)
                    
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
                    
                    // Continue with timeframe header on the new page
                    timeframe.uppercased().draw(at: CGPoint(x: tableX, y: currentY), withAttributes: timeframeAttributes)
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
            
            // Add some space after each timeframe section
            currentY += 20
            
            // Check if we need a new page before starting the next timeframe
            if currentY > context.pdfContextBounds.height - 130 && organizedVaccines.last?.0 != timeframe {
                context.beginPage()
                
                // Draw consistent background color on new page
                backgroundColor.setFill()
                UIRectFill(context.pdfContextBounds)
                
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
            }
        }
    }
    
    // Organize vaccines by timeframe
    private func organizeVaccinesByTimeframe() -> [(String, [Vaccine])] {
        // Group vaccines by their target timeframe
        var vaccinesByTimeframe: [String: [Vaccine]] = [
            "Birth": [],
            "6 Weeks": [],
            "10 Weeks": [],
            "14 Weeks": [],
            "9-12 Months": [],
            "16-24 Months": []
        ]
        
        // Logic to determine which timeframe each vaccine belongs to
        for vaccine in selectedVaccines {
            if vaccine.startWeek == 0 {
                vaccinesByTimeframe["Birth"]?.append(vaccine)
            } else if vaccine.startWeek <= 6 {
                vaccinesByTimeframe["6 Weeks"]?.append(vaccine)
            } else if vaccine.startWeek <= 10 {
                vaccinesByTimeframe["10 Weeks"]?.append(vaccine)
            } else if vaccine.startWeek <= 14 {
                vaccinesByTimeframe["14 Weeks"]?.append(vaccine)
            } else if vaccine.startWeek <= 52 { // ~12 months
                vaccinesByTimeframe["9-12 Months"]?.append(vaccine)
            } else {
                vaccinesByTimeframe["16-24 Months"]?.append(vaccine)
            }
        }
        
        // Convert to array and filter out empty sections
        let organizedVaccines = vaccinesByTimeframe.compactMap { key, vaccines in
            if !vaccines.isEmpty {
                return (timeframe: key, vaccines: vaccines)
            }
            return nil
        }.sorted { lhs, rhs in
            // Define order of timeframes
            let order: [String: Int] = [
                "Birth": 0,
                "6 Weeks": 1,
                "10 Weeks": 2,
                "14 Weeks": 3,
                "9-12 Months": 4,
                "16-24 Months": 5
            ]
            
            return (order[lhs.0] ?? 99) < (order[rhs.0] ?? 99)
        }
        
        return organizedVaccines
    }

    @objc private func continueButtonTapped() {
        if selectedVaccines.isEmpty {
            // Skip showing alert and just return if no vaccines selected
            return
        }
        
        // Add a loading indicator to the view instead of using an alert
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = view.center
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        
        // Disable the continue button while saving
        continueButton.isEnabled = false
        
        // Save the selected vaccines to the administered_vaccines table
        Task {
            do {
                // Get the baby ID with auto-fetch if needed
                let baby = try await fetchFirstConnectedBaby()
                let babyId = baby.babyID
                
                // Save the administered vaccines
                try await SupabaseVaccineManager.shared.saveAdministeredVaccines(
                    vaccines: selectedVaccines,
                    babyId: babyId,
                    administeredDates: selectedDates
                )
                
                // Mark the user as having seen the vaccine input screen
                try await FirstTimeUserManager.shared.updateHasSeenStatus(babyId: babyId, hasSeen: true)
                
                // Remove loading indicator and navigate directly
                await MainActor.run {
                    loadingIndicator.removeFromSuperview()
                    continueButton.isEnabled = true
                    
                    // Use the navigation helper to properly clear the stack
                    self.navigateToVaccineAlertViewController()
                }
            } catch {
                // Handle error without showing an alert
                await MainActor.run {
                    loadingIndicator.removeFromSuperview()
                    continueButton.isEnabled = true
                    
                    // Just print the error instead of showing an alert
                    print("❌ Error saving administered vaccines: \(error)")
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
        
        // Create date picker alert
        let alertController = UIAlertController(title: "", message: "Select a date for \(vaccine.name)", preferredStyle: .actionSheet)
        
        // Create custom view for date picker with increased height to fix cut-off dates
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: alertController.view.bounds.width - 16, height: 380))
        
        // Create and configure date picker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        
        // Remove all date constraints to allow free selection
        datePicker.minimumDate = nil
        datePicker.maximumDate = nil
        
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
        let setDateAction = UIAlertAction(title: "Set", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // Store the selected date for the vaccine
            self.selectedDates[vaccine.name] = datePicker.date
            
            // Add haptic feedback for confirmation
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            // Refresh the UI
            self.setupVaccineCards()
        }
        
        // Add remove action if date already exists
        if selectedDates[vaccine.name] != nil {
            let removeAction = UIAlertAction(title: "Remove Date", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                
                // Remove the date for this vaccine
                self.selectedDates.removeValue(forKey: vaccine.name)
                
                // Add haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
                // Refresh the UI
                self.setupVaccineCards()
            }
            alertController.addAction(removeAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(setDateAction)
        alertController.addAction(cancelAction)
        
        // For iPad support
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alertController, animated: true)
    }
}
