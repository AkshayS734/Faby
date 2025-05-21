import UIKit
import SwiftUI
import CoreLocation
import MapKit

// MARK: - Custom Calendar with Indicators
class CalendarWithIndicators: UIDatePicker {
    private var scheduledDates: Set<Date> = []
    private var dotLayers: [CALayer] = []
    var onDateSelected: ((Date) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.datePickerMode = .date
        self.preferredDatePickerStyle = .inline
        self.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        // Make the date picker more responsive to touch events
        self.isUserInteractionEnabled = true
        
        // Apply styling to ensure weekday row is visible
        self.tintColor = UIColor(hex: "#0076BA")
        self.backgroundColor = .clear
        
        // Force layout to ensure all calendar components are properly rendered
        DispatchQueue.main.async {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateIndicators()
        
        // Ensure weekday row is visible after layout
        DispatchQueue.main.async { [weak self] in
            self?.styleCalendarComponents()
        }
    }
    
    // New method to style calendar components
    private func styleCalendarComponents() {
        // Find the calendar view that contains all date components
        if let calendarView = findCalendarView() {
            // Apply any custom styling to weekday header row if needed
            styleWeekdayHeader(in: calendarView)
            
            // Make sure all components are visible
            calendarView.subviews.forEach { subview in
                subview.isHidden = false
                subview.alpha = 1.0
            }
        }
    }
    
    // Method to find and style the weekday header row
    private func styleWeekdayHeader(in view: UIView) {
        // Look for the header view that contains weekday labels
        for subview in view.subviews {
            if let collectionView = subview as? UICollectionView {
                // In UIDatePicker, header view is usually above the collection view
                if let headerView = collectionView.superview?.subviews.first(where: { $0 != collectionView }) {
                    // Make sure header is visible
                    headerView.isHidden = false
                    headerView.alpha = 1.0
                    
                    // Style weekday labels if needed
                    for case let label as UILabel in headerView.subviews {
                        label.alpha = 1.0
                        label.isHidden = false
                        // Optional: customize weekday label appearance
                        label.textColor = .secondaryLabel
                    }
                }
                break
            }
        }
    }
    
    public func updateScheduledDates(_ dates: [Date]) {
        scheduledDates.removeAll()
        
        let calendar = Calendar.current
        for date in dates {
            if let normalizedDate = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: date)) {
                scheduledDates.insert(normalizedDate)
                print("✅ Successfully added date indicator for: \(date)")
            }
        }
        
        setNeedsLayout()
    }
    
    @objc private func datePickerValueChanged() {
        print("📆 Date picker value changed to: \(self.date)")
        
        // Trigger the callback when date changes
        onDateSelected?(self.date)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.updateIndicators()
        }
    }
    
    private func updateIndicators() {
        // Reset any previous color changes
        dotLayers.forEach { $0.removeFromSuperlayer() }
        dotLayers.removeAll()
        
        // Add a short delay to ensure the calendar view has been updated
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            guard let calendarView = self.findCalendarView() else { return }
            
            // Find all date cells
            let dateCells = self.findDateCells(in: calendarView)
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            for cell in dateCells {
                if let dateLabel = self.findDateLabel(in: cell),
                   let dateText = dateLabel.text,
                   let day = Int(dateText) {
                    
                    // Create a date from the current month/year and the day number
                    let components = calendar.dateComponents([.year, .month], from: self.date)
                    if let year = components.year, let month = components.month,
                       let cellDate = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
                        
                        // Check if this date is today
                        let isToday = calendar.isDate(cellDate, inSameDayAs: today)
                        
                        // Check if this date is in our scheduled dates
                        let isScheduled = self.scheduledDates.contains(where: { scheduledDate in
                            let scheduledComponents = calendar.dateComponents([.year, .month, .day], from: scheduledDate)
                            return scheduledComponents.year == year &&
                            scheduledComponents.month == month &&
                            scheduledComponents.day == day
                        })
                        
                        // Apply styling based on date status
                        if isToday {
                            // Style for today - blue circle with white text
                            self.applyTodayStyle(to: cell, label: dateLabel)
                        } else if isScheduled {
                            // Style for scheduled dates - blue text
                            dateLabel.textColor = UIColor(hex: "#0076BA")
                        } else {
                            // Reset to default style
                            self.resetCellStyle(cell: cell, label: dateLabel)
                        }
                    }
                }
            }
        }
    }
    
    // Apply iOS-native today styling (blue circle with white text)
    private func applyTodayStyle(to cell: UIView, label: UILabel) {
        // Remove any existing background layers
        cell.layer.sublayers?.filter { $0.name == "todayCircle" }.forEach { $0.removeFromSuperlayer() }
        
        // Create circular background
        let circleLayer = CAShapeLayer()
        circleLayer.name = "todayCircle"
        circleLayer.fillColor = UIColor(hex: "#0076BA")?.cgColor
        
        // Size the circle to fit the text with padding
        let size = min(cell.bounds.width, cell.bounds.height) * 0.8
        let x = (cell.bounds.width - size) / 2
        let y = (cell.bounds.height - size) / 2
        
        let circlePath = UIBezierPath(ovalIn: CGRect(x: x, y: y, width: size, height: size))
        circleLayer.path = circlePath.cgPath
        
        // Insert the circle layer below the text
        cell.layer.insertSublayer(circleLayer, at: 0)
        
        // Set text color to white for contrast
        label.textColor = .white
    }
    
    // Reset cell to default styling
    private func resetCellStyle(cell: UIView, label: UILabel) {
        // Remove any special background
        cell.layer.sublayers?.filter { $0.name == "todayCircle" }.forEach { $0.removeFromSuperlayer() }
        
        // Reset text color to default
        label.textColor = .label
    }
    
    private func findCalendarView() -> UIView? {
        return subviews.first { subview in
            subview.subviews.contains { $0 is UICollectionView }
        }
    }
    
    private func findDateCells(in view: UIView) -> [UIView] {
        return view.subviews.flatMap { subview in
            subview.subviews.filter { cell in
                cell.subviews.contains { $0 is UILabel }
            }
        }
    }
    
    private func findDateLabel(in cell: UIView) -> UILabel? {
        return cell.subviews.first { $0 is UILabel } as? UILabel
    }
}

// MARK: - Main View Controller
class VaccineReminderViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let calendarContainer = UIView()
    private let vaccineListContainer = UIView()
    private let emptyStateView = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let loadingBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    private let loadingContainer = UIView()
    private let loadingLabel = UILabel()
    
    private var calendarWithIndicators: CalendarWithIndicators?
    private var vaccinations: [VaccineSchedule] = []
    private var filteredVaccinations: [VaccineSchedule] = []
    
    // Properties for direct navigation from HomeViewController
    var selectedVaccineId: String? // To highlight specific vaccine when navigated directly
    var selectedVaccineName: String? // For displaying name in navigation bar
    var selectedScheduleId: String? // To scroll to specific schedule
    
    // Header views
    private let headerView = UIView()
    private let scheduledVaccinationsLabel = UILabel()
    private let seeAllButton = UIButton(type: .system)
    
    // Calendar header for minimized view
    private let minimizedCalendarHeader = UIView()
    private let minimizedDateLabel = UILabel()
    private let todayDateLabel = UILabel()
    private let expandIndicator = UIImageView()
    
    // Week view for minimized calendar
    private let weekScrollView = UIScrollView()
    private let weekStackView = UIStackView()
    private var dayViews: [UIView] = []
    
    // Animation properties
    private var calendarHeightConstraint: NSLayoutConstraint?
    private var calendarTopConstraint: NSLayoutConstraint?
    private var calendarMinimizedHeight: CGFloat = 130
    private var calendarFullHeight: CGFloat = 350
    private var lastContentOffset: CGFloat = 0
    private var isCalendarMinimized = false
    
    private var currentBabyId: UUID {
        return UserDefaultsManager.shared.currentBabyId ?? UUID()
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private var vaccinationListHostingController: UIHostingController<VaccineScheduleListView>?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG: VaccineReminderViewController viewDidLoad called")
        setupUI()
        setupActivityIndicator()
        loadVaccinations()
        
        // If navigated directly from home with a specific vaccine
        if let scheduleId = selectedScheduleId {
            print("🔍 Navigated directly to vaccine with schedule ID: \(scheduleId)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadVaccinations()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        setupNavigationBar()
        setupScrollView()
        setupCalendarView()
        setupHeaderView()
        setupVaccineListContainer()
        setupEmptyStateView()
        setupLoadingIndicator()
    }
    
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        // Set custom title if navigated directly to a specific vaccine
        if let vaccineName = selectedVaccineName {
            title = vaccineName
        } else {
            title = "Vaccine Reminders"
        }
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // Search button removed as requested
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        // Add tap gesture to dismiss calendar when tapping outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsideCalendar))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    private func setupCalendarView() {
        calendarContainer.translatesAutoresizingMaskIntoConstraints = false
        calendarContainer.backgroundColor = .systemBackground
        calendarContainer.layer.cornerRadius = 12
        calendarContainer.clipsToBounds = true
        calendarContainer.layer.shadowColor = UIColor.black.cgColor
        calendarContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        calendarContainer.layer.shadowRadius = 4
        calendarContainer.layer.shadowOpacity = 0.1
        calendarContainer.layer.masksToBounds = false
        contentView.addSubview(calendarContainer)
        
        // Setup the calendar
        let datePicker = CalendarWithIndicators(frame: .zero)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.onDateSelected = { [weak self] date in
            self?.didSelectDate(date)
        }
        calendarContainer.addSubview(datePicker)
        
        // Setup minimized calendar header
        setupMinimizedCalendarHeader()
        
        self.calendarWithIndicators = datePicker
        
        calendarTopConstraint = calendarContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16)
        calendarHeightConstraint = calendarContainer.heightAnchor.constraint(equalToConstant: calendarFullHeight)
        
        NSLayoutConstraint.activate([
            calendarTopConstraint!,
            calendarContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            calendarContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            calendarHeightConstraint!,
            
            datePicker.topAnchor.constraint(equalTo: calendarContainer.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: calendarContainer.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: calendarContainer.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: calendarContainer.bottomAnchor)
        ])
        
        // Add tap gesture to the calendar container specifically for expanding minimized calendar
        let calendarTapGesture = UITapGestureRecognizer(target: self, action: #selector(calendarTapped(_:)))
        calendarTapGesture.cancelsTouchesInView = false  // Let touches pass through to the calendar
        calendarContainer.addGestureRecognizer(calendarTapGesture)
    }
    
    private func setupMinimizedCalendarHeader() {
        // Configure container view with iOS-native styling
        minimizedCalendarHeader.translatesAutoresizingMaskIntoConstraints = false
        minimizedCalendarHeader.backgroundColor = .systemBackground
        minimizedCalendarHeader.layer.cornerRadius = 16
        minimizedCalendarHeader.clipsToBounds = true
        
        // iOS-native subtle shadow
        minimizedCalendarHeader.layer.shadowColor = UIColor.black.cgColor
        minimizedCalendarHeader.layer.shadowOffset = CGSize(width: 0, height: 1)
        minimizedCalendarHeader.layer.shadowRadius = 4
        minimizedCalendarHeader.layer.shadowOpacity = 0.08
        minimizedCalendarHeader.layer.masksToBounds = false
        minimizedCalendarHeader.isHidden = true
        calendarContainer.addSubview(minimizedCalendarHeader)
        
        // Create header container with subtle blue background
        let headerContainer = UIView()
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        headerContainer.layer.cornerRadius = 12
        headerContainer.clipsToBounds = true
        minimizedCalendarHeader.addSubview(headerContainer)
        
        // Add month/year title with iOS-native styling and ensure it doesn't get cut off
        minimizedDateLabel.translatesAutoresizingMaskIntoConstraints = false
        minimizedDateLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold) // Slightly smaller font
        minimizedDateLabel.textColor = .label
        minimizedDateLabel.textAlignment = .center
        minimizedDateLabel.adjustsFontSizeToFitWidth = true // Enable text scaling
        minimizedDateLabel.minimumScaleFactor = 0.8 // Allow text to scale down if needed
        minimizedDateLabel.numberOfLines = 1
        headerContainer.addSubview(minimizedDateLabel)
        
        // Improved chevron indicator with iOS-native styling
        expandIndicator.translatesAutoresizingMaskIntoConstraints = false
        expandIndicator.contentMode = .scaleAspectFit
        expandIndicator.image = UIImage(systemName: "chevron.down")
        expandIndicator.tintColor = .systemBlue
        headerContainer.addSubview(expandIndicator)
        
        // Create the weekday row for the minimized view
        weekStackView.translatesAutoresizingMaskIntoConstraints = false
        weekStackView.axis = .horizontal
        weekStackView.distribution = .fillEqually
        weekStackView.alignment = .center
        weekStackView.spacing = 0
        minimizedCalendarHeader.addSubview(weekStackView)
        
        // Create day views for each day of the week
        createDayViews()
        
        // Set initial date values
        updateWeekViewDates(for: Date())
        
        NSLayoutConstraint.activate([
            // Container constraints
            minimizedCalendarHeader.topAnchor.constraint(equalTo: calendarContainer.topAnchor),
            minimizedCalendarHeader.leadingAnchor.constraint(equalTo: calendarContainer.leadingAnchor),
            minimizedCalendarHeader.trailingAnchor.constraint(equalTo: calendarContainer.trailingAnchor),
            minimizedCalendarHeader.bottomAnchor.constraint(equalTo: calendarContainer.bottomAnchor),
            
            // Header container with subtle blue background - increase height
            headerContainer.topAnchor.constraint(equalTo: minimizedCalendarHeader.topAnchor, constant: 12),
            headerContainer.leadingAnchor.constraint(equalTo: minimizedCalendarHeader.leadingAnchor, constant: 12),
            headerContainer.trailingAnchor.constraint(equalTo: minimizedCalendarHeader.trailingAnchor, constant: -12),
            headerContainer.heightAnchor.constraint(equalToConstant: 50), // Fixed height to prevent text clipping
            
            // Month label properly positioned with more space to prevent clipping
            minimizedDateLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            minimizedDateLabel.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            minimizedDateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: headerContainer.leadingAnchor, constant: 20),
            minimizedDateLabel.trailingAnchor.constraint(lessThanOrEqualTo: expandIndicator.leadingAnchor, constant: -16),
            
            // Chevron indicator properly positioned
            expandIndicator.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            expandIndicator.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -16),
            expandIndicator.widthAnchor.constraint(equalToConstant: 20),
            expandIndicator.heightAnchor.constraint(equalToConstant: 20),
            
            // Week stack view positioned with proper iOS-native spacing
            weekStackView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 20),
            weekStackView.leadingAnchor.constraint(equalTo: minimizedCalendarHeader.leadingAnchor, constant: 16),
            weekStackView.trailingAnchor.constraint(equalTo: minimizedCalendarHeader.trailingAnchor, constant: -16),
            weekStackView.bottomAnchor.constraint(equalTo: minimizedCalendarHeader.bottomAnchor, constant: -16),
            weekStackView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        // Update calendar minimized height for iOS-native proportions
        calendarMinimizedHeight = 165
    }
    
    private func createDayViews() {
        // Clear any existing day views
        weekStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        dayViews.removeAll()
        
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        
        for (index, dayName) in dayNames.enumerated() {
            // Create container for each day with iOS-native styling
            let dayView = UIView()
            dayView.translatesAutoresizingMaskIntoConstraints = false
            dayView.backgroundColor = .clear
            dayView.isAccessibilityElement = true
            dayView.accessibilityTraits = .button
            
            // Make day view tappable
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dayViewTapped(_:)))
            dayView.addGestureRecognizer(tapGesture)
            dayView.tag = index
            
            // Create stack view for iOS-native day layout
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 6  // iOS-native spacing
            stackView.alignment = .center
            dayView.addSubview(stackView)
            
            // Day name label with iOS-native styling
            let dayLabel = UILabel()
            dayLabel.translatesAutoresizingMaskIntoConstraints = false
            dayLabel.text = dayName
            dayLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            dayLabel.textColor = .secondaryLabel
            dayLabel.textAlignment = .center
            stackView.addArrangedSubview(dayLabel)
            
            // Circle background for selected day with iOS-native styling
            let circleView = UIView()
            circleView.translatesAutoresizingMaskIntoConstraints = false
            circleView.backgroundColor = .systemBlue
            circleView.layer.cornerRadius = 16
            circleView.isHidden = true
            dayView.insertSubview(circleView, at: 0)
            
            // Day number label with iOS-native styling
            let dateLabel = UILabel()
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            dateLabel.font = UIFont.systemFont(ofSize: 19, weight: .medium)
            dateLabel.textColor = .label
            dateLabel.textAlignment = .center
            stackView.addArrangedSubview(dateLabel)
            
            NSLayoutConstraint.activate([
                // iOS-native sizing for day view
                dayView.heightAnchor.constraint(equalToConstant: 65),
                
                // Stack view positioned for iOS-native look
                stackView.centerXAnchor.constraint(equalTo: dayView.centerXAnchor),
                stackView.centerYAnchor.constraint(equalTo: dayView.centerYAnchor),
                
                // Circle sized and positioned for iOS-native look
                circleView.centerXAnchor.constraint(equalTo: dateLabel.centerXAnchor),
                circleView.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
                circleView.widthAnchor.constraint(equalToConstant: 32),
                circleView.heightAnchor.constraint(equalToConstant: 32)
            ])
            
            weekStackView.addArrangedSubview(dayView)
            dayViews.append(dayView)
        }
    }
    
    private func updateWeekViewDates(for date: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        
        // Get the start of the week (Sunday)
        let weekday = calendar.component(.weekday, from: today) - 1 // 0-based index (0 = Sunday)
        let startOfWeek = calendar.date(byAdding: .day, value: -weekday, to: today)!
        
        // Update month/year label with iOS-native formatting and ensure it doesn't get cut off
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        minimizedDateLabel.text = formatter.string(from: date)
        
        // Ensure the label is properly laid out
        minimizedDateLabel.setNeedsLayout()
        minimizedDateLabel.layoutIfNeeded()
        
        // Update each day view with the correct date and iOS-native styling
        for (index, dayView) in dayViews.enumerated() {
            if let stackView = dayView.subviews.first(where: { $0 is UIStackView }) as? UIStackView,
               let dayLabel = stackView.arrangedSubviews.first as? UILabel,
               let dateLabel = stackView.arrangedSubviews.last as? UILabel,
               let circleView = dayView.subviews.first(where: { $0 != stackView }) {
                
                // Calculate date for this day view
                if let dayDate = calendar.date(byAdding: .day, value: index, to: startOfWeek) {
                    // Set the date number with iOS-native formatting
                    let dayNumber = calendar.component(.day, from: dayDate)
                    dateLabel.text = "\(dayNumber)"
                    
                    // Check if this is today
                    let isToday = calendar.isDate(dayDate, inSameDayAs: today)
                    
                    // Apply iOS-native styling for today
                    if isToday {
                        circleView.isHidden = false
                        dateLabel.textColor = .white
                        dayLabel.textColor = .systemBlue
                    } else {
                        circleView.isHidden = true
                        dateLabel.textColor = .label
                        dayLabel.textColor = .secondaryLabel
                    }
                    
                    // Set accessibility label with iOS-native format
                    let dayFormatter = DateFormatter()
                    dayFormatter.dateStyle = .medium
                    dayView.accessibilityLabel = "\(dayLabel.text ?? ""), \(dayFormatter.string(from: dayDate))"
                }
            }
        }
    }
    
    private func toggleCalendarSizes(minimize: Bool, animated: Bool = true) {
        print("🔄 Toggling calendar size - minimize: \(minimize), current state minimized: \(isCalendarMinimized)")
        
        // Skip if already in the requested state
        if isCalendarMinimized == minimize {
            return
        }
        
        isCalendarMinimized = minimize
        
        if minimize {
            minimizedCalendarHeader.isHidden = false
            updateWeekViewDates(for: calendarWithIndicators?.date ?? Date())
        } else {
            minimizedCalendarHeader.isHidden = true
        }
        
        let targetHeight = minimize ? calendarMinimizedHeight : calendarFullHeight
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.calendarHeightConstraint?.constant = targetHeight
                self.calendarWithIndicators?.alpha = minimize ? 0 : 1
                self.minimizedCalendarHeader.alpha = minimize ? 1 : 0
                self.expandIndicator.transform = minimize ? .identity : CGAffineTransform(rotationAngle: .pi)
                self.view.layoutIfNeeded()
            }
        } else {
            calendarHeightConstraint?.constant = targetHeight
            calendarWithIndicators?.alpha = minimize ? 0 : 1
            minimizedCalendarHeader.alpha = minimize ? 1 : 0
            expandIndicator.transform = minimize ? .identity : CGAffineTransform(rotationAngle: .pi)
            view.layoutIfNeeded()
        }
    }
    
    private func setupHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerView)
        
        scheduledVaccinationsLabel.translatesAutoresizingMaskIntoConstraints = false
        scheduledVaccinationsLabel.text = "Scheduled Vaccinations"
        scheduledVaccinationsLabel.font = .systemFont(ofSize: 20, weight: .bold)
        headerView.addSubview(scheduledVaccinationsLabel)
        
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        seeAllButton.setTitle("See All", for: .normal)
        seeAllButton.titleLabel?.font = .systemFont(ofSize: 16)
        seeAllButton.addTarget(self, action: #selector(seeAllButtonTapped), for: .touchUpInside)
        headerView.addSubview(seeAllButton)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: calendarContainer.bottomAnchor, constant: 24),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 30),
            
            scheduledVaccinationsLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            scheduledVaccinationsLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            seeAllButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            seeAllButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
    }
    
    private func setupVaccineListContainer() {
        vaccineListContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(vaccineListContainer)
        
        NSLayoutConstraint.activate([
            vaccineListContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            vaccineListContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            vaccineListContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            vaccineListContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            vaccineListContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 500) // Ensure enough space for content
        ])
    }
    
    private func setupEmptyStateView() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.backgroundColor = .clear
        contentView.addSubview(emptyStateView)
        
        // Create iOS-native empty state container
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        emptyStateView.addSubview(containerView)
        
        // Create stack view for content
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        containerView.addSubview(stackView)
        
        // Create iOS-style empty state image
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .tertiaryLabel
        
        // Use SF Symbol that matches the app's theme
        if #available(iOS 15.0, *) {
            imageView.image = UIImage(systemName: "syringe", withConfiguration: UIImage.SymbolConfiguration(pointSize: 70, weight: .light))
        } else {
            imageView.image = UIImage(systemName: "calendar.badge.exclamationmark")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .light))
        }
        
        // Create iOS-style title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "No Vaccinations Scheduled"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        
        // Create iOS-style subtitle label
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "There are no upcoming vaccinations for this date."
        subtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        
        // Add views to stack
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        
        // Add constraints
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor),
            containerView.widthAnchor.constraint(lessThanOrEqualTo: emptyStateView.widthAnchor, constant: -40),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            imageView.heightAnchor.constraint(equalToConstant: 90),
            imageView.widthAnchor.constraint(equalToConstant: 90),
            
            emptyStateView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            emptyStateView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // Initially hidden
        emptyStateView.isHidden = true
    }
    
    private func setupLoadingIndicator() {
        // Create container for loading UI with blur effect (Apple style)
        loadingBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        loadingBackgroundView.layer.cornerRadius = 12
        loadingBackgroundView.clipsToBounds = true
        view.addSubview(loadingBackgroundView)
        
        loadingContainer.translatesAutoresizingMaskIntoConstraints = false
        loadingBackgroundView.contentView.addSubview(loadingContainer)
        
        // Configure activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .label
        loadingContainer.addSubview(activityIndicator)
        
        // Add loading label
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.text = "Loading..."
        loadingLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        loadingLabel.textColor = .label
        loadingLabel.textAlignment = .center
        loadingContainer.addSubview(loadingLabel)
        
        // Set up constraints for Apple-style loading indicator
        NSLayoutConstraint.activate([
            loadingBackgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingBackgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingBackgroundView.widthAnchor.constraint(equalToConstant: 120),
            loadingBackgroundView.heightAnchor.constraint(equalToConstant: 100),
            
            loadingContainer.topAnchor.constraint(equalTo: loadingBackgroundView.contentView.topAnchor),
            loadingContainer.leadingAnchor.constraint(equalTo: loadingBackgroundView.contentView.leadingAnchor),
            loadingContainer.trailingAnchor.constraint(equalTo: loadingBackgroundView.contentView.trailingAnchor),
            loadingContainer.bottomAnchor.constraint(equalTo: loadingBackgroundView.contentView.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: loadingContainer.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: loadingContainer.topAnchor, constant: 20),
            
            loadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 12),
            loadingLabel.leadingAnchor.constraint(equalTo: loadingContainer.leadingAnchor, constant: 10),
            loadingLabel.trailingAnchor.constraint(equalTo: loadingContainer.trailingAnchor, constant: -10),
        ])
        
        // Hide initially
        loadingBackgroundView.isHidden = true
    }
    
    @objc private func handleTapOutsideCalendar(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: contentView)
        if !calendarContainer.frame.contains(location) && isCalendarMinimized == false {
            toggleCalendarSizes(minimize: true)
        }
    }
    
    // MARK: - Action Handlers
    @objc private func seeAllButtonTapped() {
        // Reset any date filters
        filteredVaccinations = vaccinations
        displayVaccinations(filteredVaccinations)
        scheduledVaccinationsLabel.text = "All Scheduled Vaccinations"
    }
    
    // MARK: - Helper methods for vaccine name resolution
    private func getVaccineName(for vaccineId: UUID) async -> String {
        print("🔍 Getting vaccine name for ID: \(vaccineId)")
        do {
            // Use SupabaseVaccineManager to fetch all vaccines
            let allVaccines = try await SupabaseVaccineManager.shared.fetchAllVaccines()
            
            // Find the matching vaccine by ID
            if let vaccine = allVaccines.first(where: { $0.id == vaccineId }) {
                print("✅ Found vaccine name from database: \(vaccine.name)")
                return vaccine.name
            }
            
            // Fallback to VaccineManager's static data if needed
            for stage in VaccineManager.shared.vaccineData {
                for vaccineName in stage.vaccines {
                    // This is a simple check - in practice you'd want to match more precisely
                    if vaccineName.contains(vaccineId.uuidString.prefix(8)) {
                        print("✅ Found vaccine name from static data: \(vaccineName)")
                        return vaccineName
                    }
                }
            }
            
            print("⚠️ Could not find name for vaccine ID: \(vaccineId)")
            return "Unknown Vaccine"
        } catch {
            print("❌ Error fetching vaccine name: \(error)")
            
            // Fallback to shortened UUID
            return "Vaccine \(vaccineId.uuidString.prefix(8))"
        }
    }
    
    // MARK: - Data Loading and Display
    private func loadVaccinations() {
        print("📋 Loading vaccinations for all babies")
        
        // Show Apple-style loading indicator for initial data load
        loadingBackgroundView.isHidden = false
        activityIndicator.startAnimating()
        
        Task {
            do {
                // Fetch all scheduled vaccines (no baby filter)
                let scheduledVaccines = try await VaccineScheduleManager.shared.fetchAllSchedules()
                print("✅ Fetched \(scheduledVaccines.count) scheduled vaccines (all babies)")
                
                // Process and combine records
                // Filter out administered vaccines before processing
                let filteredScheduledVaccines = scheduledVaccines.filter { !$0.isAdministered }
                let combinedRecords = processVaccinationRecords(
                    scheduledVaccines: filteredScheduledVaccines,
                    administeredVaccines: []
                )
                
                // Update calendar with vaccine dates
                let vaccineDates = combinedRecords.map { $0.date }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.vaccinations = combinedRecords
                    self.filteredVaccinations = combinedRecords
                    self.calendarWithIndicators?.updateScheduledDates(vaccineDates)
                    
                    // Hide loading indicator before displaying vaccinations
                    self.loadingBackgroundView.isHidden = true
                    self.activityIndicator.stopAnimating()
                    
                    // Now display vaccinations without loading indicator
                    self.displayVaccinations(combinedRecords)
                    
                    // If navigated directly to a specific vaccine, highlight and scroll to it
                    if let selectedScheduleId = self.selectedScheduleId {
                        self.highlightSelectedVaccine(scheduleId: selectedScheduleId)
                    }
                }
            } catch {
                print("❌ Error loading vaccinations: \(error)")
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    // Hide Apple-style loading indicator
                    self.loadingBackgroundView.isHidden = true
                    self.activityIndicator.stopAnimating()
                    
                    self.showErrorAlert(message: "Unable to load vaccination schedules. Please try again later.")
                    self.vaccinations = []
                    self.filteredVaccinations = []
                    self.displayVaccinations([])
                }
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func highlightSelectedVaccine(scheduleId: String) {
        print("👁️ Attempting to highlight vaccine with schedule ID: \(scheduleId)")
        
        // Find the target vaccine in our vaccine list
        guard let targetVaccine = vaccinations.first(where: { $0.id.uuidString == scheduleId }),
              let hostingController = vaccinationListHostingController else {
            print("❌ Could not find vaccine with ID: \(scheduleId)")
            return
        }
        
        // Set the vaccine date as the selected date in the calendar
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            // Scroll to the selected date in the calendar
            if let calendarPicker = self.calendarWithIndicators {
                calendarPicker.date = targetVaccine.date
                self.didSelectDate(targetVaccine.date)
            }
            
            // Post notification to scroll to specific vaccine (will be handled by SwiftUI view)
            NotificationCenter.default.post(
                name: Notification.Name("ScrollToVaccine"),
                object: nil,
                userInfo: ["scheduleId": scheduleId]
            )
            
            // Add visual indicator of selection with animation
            self.addTemporaryHighlight()
        }
    }
    
    private func addTemporaryHighlight() {
        // Create a flash effect for the highlighted vaccine
        let flashView = UIView(frame: vaccineListContainer.bounds)
        flashView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        flashView.alpha = 0
        vaccineListContainer.addSubview(flashView)
        
        // Animate the flash effect
        UIView.animate(withDuration: 0.3, animations: {
            flashView.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
                flashView.alpha = 0
            }, completion: { _ in
                flashView.removeFromSuperview()
            })
        })
    }
    
    private func processVaccinationRecords(
        scheduledVaccines: [VaccineSchedule],
        administeredVaccines: [VaccineAdministered]
    ) -> [VaccineSchedule] {
        var result: [VaccineSchedule] = []
        
        // Add scheduled vaccines that are not administered
        result.append(contentsOf: scheduledVaccines.filter { !$0.isAdministered })
        
        // Convert administered vaccines to the same model for display
        for administered in administeredVaccines {
            // Find the matching scheduled vaccine to get more details
            if let matchingSchedule = scheduledVaccines.first(where: { $0.id == administered.scheduleId }) {
                // Create a new schedule record with administered status
                let administeredSchedule = VaccineSchedule(
                    id: administered.id,
                    babyID: administered.babyId,
                    vaccineId: administered.vaccineId,
                    hospital: matchingSchedule.hospital,
                    date: administered.administeredDate,
                    location: matchingSchedule.location,
                    isAdministered: true
                )
                result.append(administeredSchedule)
            }
        }
        
        // Sort by date (newest first)
        result.sort { (a, b) -> Bool in
            return a.date < b.date // Changed to date ascending (upcoming first)
        }
        
        return result
    }
    
    private func displayVaccinations(_ vaccinationsToDisplay: [VaccineSchedule]? = nil) {
        let vaccines = vaccinationsToDisplay ?? filteredVaccinations
        
        // Create vaccine schedule tuples with names
        var vaccinesWithNames: [(VaccineSchedule, String)] = []
        
        // Create a task group to fetch all vaccine names asynchronously
        Task {
            if vaccines.isEmpty {
                // If there are no vaccines, update UI immediately
                await MainActor.run {
                    // Always maintain the same background by not removing and re-adding the view controller
                    if vaccinationListHostingController == nil {
                        // Only create a new one if it doesn't exist
                        let emptyListView = VaccineScheduleListView(vaccinations: [])
                        let hostingController = UIHostingController(rootView: emptyListView)
                        addChild(hostingController)
                        hostingController.view.backgroundColor = .systemGroupedBackground
                        vaccineListContainer.addSubview(hostingController.view)
                        
                        // Setup constraints for the hosting controller
                        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                        NSLayoutConstraint.activate([
                            hostingController.view.topAnchor.constraint(equalTo: vaccineListContainer.topAnchor),
                            hostingController.view.leadingAnchor.constraint(equalTo: vaccineListContainer.leadingAnchor),
                            hostingController.view.trailingAnchor.constraint(equalTo: vaccineListContainer.trailingAnchor),
                            hostingController.view.bottomAnchor.constraint(equalTo: vaccineListContainer.bottomAnchor)
                        ])
                        
                        hostingController.didMove(toParent: self)
                        vaccinationListHostingController = hostingController
                    }
                    
                    // Update empty state visibility
                    emptyStateView.isHidden = false
                    vaccineListContainer.isHidden = true
                }
                return
            }
            
            for vaccine in vaccines {
                // Get the vaccine name using the getVaccineName method
                let vaccineName = await getVaccineName(for: vaccine.vaccineId)
                vaccinesWithNames.append((vaccine, vaccineName))
            }
            
            // Update UI on the main thread once all names are retrieved
            await MainActor.run {
                // Update view rather than replace if possible
                if let existingController = vaccinationListHostingController {
                    // Update the existing view instead of creating a new one
                    let updatedView = VaccineScheduleListView(vaccinations: vaccinesWithNames)
                    existingController.rootView = updatedView
                } else {
                    // Create and add the new SwiftUI vaccination list view with vaccine names
                    let vaccinationListView = VaccineScheduleListView(vaccinations: vaccinesWithNames)
                    let hostingController = UIHostingController(rootView: vaccinationListView)
                    addChild(hostingController)
                    hostingController.view.backgroundColor = .systemGroupedBackground
                    vaccineListContainer.addSubview(hostingController.view)
                    
                    // Setup constraints for the hosting controller
                    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        hostingController.view.topAnchor.constraint(equalTo: vaccineListContainer.topAnchor),
                        hostingController.view.leadingAnchor.constraint(equalTo: vaccineListContainer.leadingAnchor),
                        hostingController.view.trailingAnchor.constraint(equalTo: vaccineListContainer.trailingAnchor),
                        hostingController.view.bottomAnchor.constraint(equalTo: vaccineListContainer.bottomAnchor)
                    ])
                    
                    hostingController.didMove(toParent: self)
                    vaccinationListHostingController = hostingController
                }
                
                // Update empty state visibility
                emptyStateView.isHidden = true
                vaccineListContainer.isHidden = false
                
                // No need to toggle calendar size here because it's handled in didSelectDate
            }
        }
    }
    
    // MARK: - Date Selection
    private func didSelectDate(_ date: Date) {
        print("📅 Date selected: \(date)")
        
        // Keep calendar minimized when selecting dates
        if !isCalendarMinimized {
            toggleCalendarSizes(minimize: true, animated: true)
        }
        
        // Filter vaccinations without showing loading (no need to reload background)
        filterVaccinationsForDate(date, showLoading: false)
    }
    
    private func filterVaccinationsForDate(_ selectedDate: Date, showLoading: Bool = false) {
        print("🔍 Filtering vaccinations for date: \(selectedDate)")
        
        // Only show loading if explicitly requested (initial load)
        if showLoading {
            loadingBackgroundView.isHidden = false
            activityIndicator.startAnimating()
        }
        
        let calendar = Calendar.current
        let selectedComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        
        // First check if we have any vaccinations at all
        if vaccinations.isEmpty {
            print("⚠️ No vaccinations available to filter")
            if showLoading {
                loadingBackgroundView.isHidden = true
                activityIndicator.stopAnimating()
            }
            displayVaccinations([])
            scheduledVaccinationsLabel.text = "No vaccinations for \(dateFormatter.string(from: selectedDate))"
            return
        }
        
        // Filter vaccinations by date
        filteredVaccinations = vaccinations.filter { vaccination in
            let vaccinationComponents = calendar.dateComponents([.year, .month, .day], from: vaccination.date)
            
            let matches = selectedComponents.year == vaccinationComponents.year &&
                          selectedComponents.month == vaccinationComponents.month &&
                          selectedComponents.day == vaccinationComponents.day
            
            if matches {
                print("✅ Found matching vaccination: \(vaccination.hospital) on \(vaccination.date)")
            }
            
            return matches
        }
        
        // Update UI with filtered vaccinations
        print("🔢 Found \(filteredVaccinations.count) vaccinations for selected date")
        
        if showLoading {
            loadingBackgroundView.isHidden = true
            activityIndicator.stopAnimating()
        }
        
        displayVaccinations(filteredVaccinations)
        
        if filteredVaccinations.isEmpty {
            scheduledVaccinationsLabel.text = "No vaccinations for \(dateFormatter.string(from: selectedDate))"
        } else {
            scheduledVaccinationsLabel.text = "Vaccinations for : )"
        }
    }
    
    // Search functionality removed as requested
    
    // Search functionality has been removed
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Detect scroll direction
        let currentOffset = scrollView.contentOffset.y
        let scrollDirection = currentOffset > lastContentOffset ? "down" : "up"
        
        // Allow calendar to expand when scrolling up/down based on gesture
        if scrollDirection == "down" && currentOffset > 10 {
            // Scrolling down - minimize calendar
            if !isCalendarMinimized {
                toggleCalendarSizes(minimize: true)
            }
        } else if scrollDirection == "up" && lastContentOffset - currentOffset > 20 {
            // Significant scroll up - expand calendar
            if isCalendarMinimized && currentOffset < 50 {
                toggleCalendarSizes(minimize: false)
            }
        }
        
        // Update for next comparison
        lastContentOffset = currentOffset
    }
    
    // Add a tap gesture to the minimized calendar to expand it
    @objc private func calendarTapped(_ sender: UITapGestureRecognizer) {
        // Get the tap location
        let location = sender.location(in: calendarContainer)
        print("👆 Calendar tapped at point: \(location), calendar minimized: \(isCalendarMinimized)")
        
        // Always expand if the calendar is minimized
        if isCalendarMinimized {
            print("⬆️ Expanding minimized calendar")
            toggleCalendarSizes(minimize: false)
            return
        }
        
        // For expanded calendar, only minimize if not tapping on the date picker
        if let datePicker = calendarWithIndicators {
            let pickerLocation = calendarContainer.convert(location, to: datePicker)
            if !datePicker.bounds.contains(pickerLocation) {
                print("⬇️ Minimizing expanded calendar (tap outside date picker)")
                toggleCalendarSizes(minimize: true)
            } else {
                print("👈 Tap is inside date picker, not toggling calendar")
            }
        }
    }
    
    @objc private func dayViewTapped(_ sender: UITapGestureRecognizer) {
        print("👆 Day tapped in minimized calendar")
        guard let dayView = sender.view, isCalendarMinimized else { return }
        
        // Calculate the date for the tapped day
        let calendar = Calendar.current
        let currentDate = calendarWithIndicators?.date ?? Date()
        let today = calendar.startOfDay(for: currentDate)
        
        // Get the start of the week (Sunday)
        let weekday = calendar.component(.weekday, from: today) - 1 // 0-based index (0 = Sunday)
        let startOfWeek = calendar.date(byAdding: .day, value: -weekday, to: today)!
        
        // Calculate the date for the tapped day
        if let selectedDate = calendar.date(byAdding: .day, value: dayView.tag, to: startOfWeek) {
            print("📅 Selected date in minimized calendar: \(selectedDate)")
            
            // Update the full calendar's date without showing it
            calendarWithIndicators?.date = selectedDate
            
            // Visual feedback on tap
            UIView.animate(withDuration: 0.1, animations: {
                dayView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    dayView.transform = .identity
                }
            })
            
            // Update the selected day visuals
            for (index, view) in dayViews.enumerated() {
                if let stackView = view.subviews.first(where: { $0 is UIStackView }) as? UIStackView,
                   let dayLabel = stackView.arrangedSubviews.first as? UILabel,
                   let dateLabel = stackView.arrangedSubviews.last as? UILabel,
                   let circleView = view.subviews.first(where: { $0 != stackView }) {
                    
                    if index == dayView.tag {
                        // This is the selected day
                        if !calendar.isDateInToday(selectedDate) {
                            circleView.isHidden = false
                            circleView.backgroundColor = .systemBlue.withAlphaComponent(0.2)
                            dateLabel.textColor = .systemBlue
                            dayLabel.textColor = .systemBlue
                        }
                    } else if !calendar.isDateInToday(calendar.date(byAdding: .day, value: index, to: startOfWeek)!) {
                        // Reset other days (except today)
                        circleView.isHidden = true
                        dateLabel.textColor = .label
                        dayLabel.textColor = .secondaryLabel
                    }
                }
            }
            
            // Filter vaccinations for the selected date while keeping calendar minimized
            filterVaccinationsForDate(selectedDate, showLoading: false)
        }
    }
    
    // MARK: - Overdue Vaccine Methods
    
    /// Check for overdue vaccines and return them
    func checkForOverdueVaccines() async -> [(VaccineSchedule, String)] {
        do {
            // Try using VaccineScheduleManager first
            return try await VaccineScheduleManager.shared.fetchOverdueVaccines()
        } catch {
            print("❌ Error fetching overdue vaccines from VaccineScheduleManager: \(error)")
            
            // Fallback to SupabaseVaccineManager
            do {
                return try await SupabaseVaccineManager.shared.fetchOverdueVaccines()
            } catch {
                print("❌ Error fetching overdue vaccines from SupabaseVaccineManager: \(error)")
                return []
            }
        }
    }
    
    /// Show an alert for an overdue vaccine
    func showOverdueVaccineAlert(for vaccineSchedule: VaccineSchedule, withName vaccineName: String) {
        // Create an iOS-native alert
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let alert = UIAlertController(
            title: "Overdue Vaccine",
            message: "The \(vaccineName) vaccine was scheduled for \(dateFormatter.string(from: vaccineSchedule.date)). Has it been administered?",
            preferredStyle: .alert
        )
        
        // Add Yes action (mark as administered)
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            Task {
                do {
                    try await SupabaseVaccineManager.shared.markVaccineAsAdministered(
                        scheduleId: vaccineSchedule.id.uuidString,
                        administeredDate: Date()
                    )
                    
                    // Refresh the view
                    await MainActor.run {
                        self?.loadVaccinations()
                    }
                } catch {
                    print("❌ Error marking vaccine as administered: \(error)")
                }
            }
        })
        
        // Add Remind Later action
        alert.addAction(UIAlertAction(title: "Remind Me Later", style: .default))
        
        // Add No action (dismiss the alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        // Present the alert
        present(alert, animated: true)
    }
    
    /// Static method that can be called by other view controllers to present an alert
    static func presentOverdueVaccineAlert(for vaccineSchedule: VaccineSchedule, withName vaccineName: String, on viewController: UIViewController) {
        // Create an iOS-native alert
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let alert = UIAlertController(
            title: "Overdue Vaccine",
            message: "The \(vaccineName) vaccine was scheduled for \(dateFormatter.string(from: vaccineSchedule.date)). Has it been administered?",
            preferredStyle: .alert
        )
        
        // Add Yes action (mark as administered)
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            Task {
                do {
                    try await SupabaseVaccineManager.shared.markVaccineAsAdministered(
                        scheduleId: vaccineSchedule.id.uuidString,
                        administeredDate: Date()
                    )
                    
                    // Notify observers to refresh data
                    await MainActor.run {
                        NotificationCenter.default.post(name: .vaccinesUpdated, object: nil)
                        
                        // Show success alert
                        let successAlert = UIAlertController(
                            title: "Success",
                            message: "The vaccine has been marked as administered.",
                            preferredStyle: .alert
                        )
                        successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        viewController.present(successAlert, animated: true)
                    }
                } catch {
                    print("❌ Error marking vaccine as administered: \(error)")
                    
                    // Show error alert
                    await MainActor.run {
                        let errorAlert = UIAlertController(
                            title: "Error",
                            message: "Failed to mark the vaccine as administered. Please try again.",
                            preferredStyle: .alert
                        )
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        viewController.present(errorAlert, animated: true)
                    }
                }
            }
        })
        
        // Add Remind Later action
        alert.addAction(UIAlertAction(title: "Remind Me Later", style: .default))
        
        // Add No action (dismiss the alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        // Present the alert
        viewController.present(alert, animated: true)
    }
}

// MARK: - SwiftUI Views
struct VaccineScheduleListView: View {
    let vaccinations: [(VaccineSchedule, String)]
    
    var body: some View {
        if vaccinations.isEmpty {
            VStack {
                Spacer()
                Text("No vaccinations found")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(vaccinations, id: \.0.id) { tuple in
                        let (vaccination, vaccineName) = tuple
                        VaccinationCard(vaccination: vaccination, vaccineName: vaccineName)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct VaccinationCard: View {
    let vaccination: VaccineSchedule
    let vaccineName: String
    @State private var locationText: String = ""
    @State private var coordinates: (latitude: Double, longitude: Double)? = nil
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(vaccineName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(vaccination.isAdministered ? "Administered" : "Rescheduled")
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(vaccination.isAdministered ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                    )
                    .foregroundColor(vaccination.isAdministered ? .green : .blue)
            }
            
            Divider()
            
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                Text(dateFormatter.string(from: vaccination.date))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                Image(systemName: "building.2")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                Text(vaccination.hospital)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if !vaccination.location.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    Text(locationText.isEmpty ? "Loading location..." : locationText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Apple Maps navigation button - moved to location row
                    Button(action: {
                        openMapsNavigation()
                    }) {
                        HStack(spacing: 4) {
                            Text("Navigate")
                                .font(.footnote)
                                .fontWeight(.medium)
                            Image(systemName: "location.fill")
                                .font(.footnote)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                        .foregroundColor(.blue)
                    }
                }
            } else {
                // If no location specified, show navigate button with hospital name only
                HStack(spacing: 12) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    Text("No specific location")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Apple Maps navigation button for hospital name search
                    Button(action: {
                        openMapsNavigation()
                    }) {
                        HStack(spacing: 4) {
                            Text("Navigate")
                                .font(.footnote)
                                .fontWeight(.medium)
                            Image(systemName: "map.fill")
                                .font(.footnote)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        .onAppear {
            geocodeLocation(from: vaccination.location)
        }
    }
    
    // Function to open Apple Maps for navigation to the hospital
    private func openMapsNavigation() {
        // Try using coordinates first if available
        if let coords = coordinates {
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: coords.latitude, longitude: coords.longitude)))
            mapItem.name = vaccination.hospital
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            return
        }
        
        // If coordinates not available, try using hospital name and location text
        let addressString = "\(vaccination.hospital), \(locationText.isEmpty ? vaccination.location : locationText)"
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(addressString) { placemarks, error in
            if let error = error {
                print("❌ Geocoding error: \(error)")
                // Fallback to Maps search if geocoding fails
                let searchQuery = addressString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                if let url = URL(string: "http://maps.apple.com/?q=\(searchQuery)") {
                    UIApplication.shared.open(url)
                }
                return
            }
            
            if let placemark = placemarks?.first, let location = placemark.location {
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
                mapItem.name = vaccination.hospital
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            } else {
                // Fallback to Maps search
                let searchQuery = addressString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                if let url = URL(string: "http://maps.apple.com/?q=\(searchQuery)") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    // Convert coordinates string to a formatted location name
    private func geocodeLocation(from coordinatesString: String) {
        // If the string doesn't look like coordinates, use it as is
        if !coordinatesString.contains(",") {
            locationText = coordinatesString
            return
        }
        
        // Extract coordinates from string (format expected: "latitude,longitude")
        let components = coordinatesString.components(separatedBy: ",")
        guard components.count == 2,
              let latitude = Double(components[0].trimmingCharacters(in: .whitespacesAndNewlines)),
              let longitude = Double(components[1].trimmingCharacters(in: .whitespacesAndNewlines)) else {
            locationText = coordinatesString
            return
        }
        
        // Store coordinates for navigation
        coordinates = (latitude, longitude)
        
        // Use CLGeocoder to get a readable location name
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("❌ Reverse geocoding error: \(error.localizedDescription)")
                // If geocoding fails, display the coordinates in a readable format
                DispatchQueue.main.async {
                    locationText = String(format: "%.5f, %.5f", latitude, longitude)
                }
                return
            }
            
            if let placemark = placemarks?.first {
                // Format the placemark to a readable address
                var addressComponents: [String] = []
                
                if let subLocality = placemark.subLocality {
                    addressComponents.append(subLocality)
                }
                
                if let locality = placemark.locality {
                    addressComponents.append(locality)
                }
                
                if let administrativeArea = placemark.administrativeArea {
                    addressComponents.append(administrativeArea)
                }
                
                let formattedAddress = addressComponents.joined(separator: ", ")
                
                DispatchQueue.main.async {
                    locationText = formattedAddress.isEmpty ? coordinatesString : formattedAddress
                }
            } else {
                // If no placemark returned, display the coordinates
                DispatchQueue.main.async {
                    locationText = String(format: "%.5f, %.5f", latitude, longitude)
                }
            }
        }
    }
}
