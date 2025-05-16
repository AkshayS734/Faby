import UIKit
import SwiftUI

class GrowTrackViewController: UIViewController, MilestonesOverviewDelegate{

    @IBOutlet weak var topSegmentedControl: UISegmentedControl!
    
//    @IBAction func showMilestoneOverviewTapped(_ sender: UIBarButtonItem) {
//        let milestonesVC = MilestonesOverviewViewController()
//        milestonesVC.delegate = self
//        navigationController?.pushViewController(milestonesVC, animated: true)
//    }
    
    var baby: Baby?
    var dataController: DataController {
        return DataController.shared
    }
    
    
    private var monthButtonCollectionView: ButtonsCollectionView!
    private var categoryButtonCollectionView: ButtonsCollectionView!
    private var milestonesCollectionView: UICollectionView!
    private var filteredMilestones: [GrowthMilestone] = []
    private let monthButtonTitles = ["12 months", "15 months", "18 months", "24 months", "30 months", "36 months"]
    private let monthButtonSize = CGSize(width: 90, height: 100)
    private let categoryButtonTitles = ["Cognitive", "Language", "Physical", "Social"]
    private let categoryButtonSize = CGSize(width: 110, height: 50)
    private let categoryButtonImages: [UIImage] = [
        UIImage(systemName: "brain.head.profile")!,
        UIImage(systemName: "text.bubble")!,
        UIImage(systemName: "figure.walk")!,
        UIImage(systemName: "person.2.fill")!
    ]
    
    
    @IBOutlet weak var bodyMeasurementCollectionView: UICollectionView!
    private var bodyMeasurements = ["Height", "Weight", "Head Circumference"]
    private var measurements : [BabyMeasurement] = []
    let units = ["cm", "kg", "cm"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let baby = dataController.baby else {
            print("Baby not initialized")
            return
        }
        
        self.baby = baby
        view.backgroundColor = .systemGray6
        
        setupMeasurementCallback()
//        setupNavigationBar()
        setupMonthButtons()
        setupCategoryButtons()
        setupMilestonesCollectionView()
        setupBodyMeasurementCollectionView()
        
        loadInitialData(for: baby)
    }
    
    private func setupMeasurementCallback() {
        baby?.measurementUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.bodyMeasurementCollectionView.reloadData()
            }
        }
    }

//    private func setupNavigationBar() {
//        let icon = UIImage(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")?.withRenderingMode(.alwaysOriginal)
//        let button = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(showMilestoneOverviewTapped))
//        navigationItem.rightBarButtonItem = button
//    }

    private func setupMonthButtons() {
        monthButtonCollectionView = ButtonsCollectionView(
            buttonTitles: monthButtonTitles,
            categoryButtonTitles: [],
            categoryButtonImages: [],
            buttonSize: monthButtonSize,
            minimumLineSpacing: 5,
            cornerRadius: 10
        )
        monthButtonCollectionView.delegate = self
        view.addSubview(monthButtonCollectionView)
        setupMonthCollectionView()
        monthButtonCollectionView.selectButton(at: 0)
    }

    private func setupCategoryButtons() {
        categoryButtonCollectionView = ButtonsCollectionView(
            buttonTitles: categoryButtonTitles,
            categoryButtonTitles: categoryButtonTitles,
            categoryButtonImages: categoryButtonImages,
            buttonSize: categoryButtonSize,
            minimumLineSpacing: 5,
            cornerRadius: 7
        )
        categoryButtonCollectionView.delegate = self
        view.addSubview(categoryButtonCollectionView)
        setupCategoryCollectionView()
        categoryButtonCollectionView.selectButton(at: 0)
    }

    private func setupBodyMeasurementCollectionView() {
        let nib = UINib(nibName: "BodyMeasurementCollectionViewCell", bundle: nil)
        bodyMeasurementCollectionView.register(nib, forCellWithReuseIdentifier: "BodyMeasurementCollectionViewCell")
        
        bodyMeasurementCollectionView.dataSource = self
        bodyMeasurementCollectionView.delegate = self
        bodyMeasurementCollectionView.isHidden = true
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: view.frame.width - 32, height: 175)
        bodyMeasurementCollectionView.collectionViewLayout = layout
        
        bodyMeasurementCollectionView.reloadData()
    }

    private func loadInitialData(for baby: Baby) {
        dataController.loadMeasurements(for: baby.babyID) { [weak self] in
            DispatchQueue.main.async {
                self?.measurements = self?.dataController.measurements ?? []
                self?.bodyMeasurementCollectionView.reloadData()
            }
        }
        
        dataController.loadMilestones(for: baby.babyID.uuidString) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.filterMilestones(
                    month: self.monthButtonTitles[0],
                    category: self.categoryButtonTitles[0]
                )
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }

    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
    }
    
    private func setupMonthCollectionView() {
        monthButtonCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            monthButtonCollectionView.topAnchor.constraint(equalTo: topSegmentedControl.bottomAnchor, constant: 20),
            monthButtonCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            monthButtonCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            monthButtonCollectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    private func setupCategoryCollectionView() {
        categoryButtonCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryButtonCollectionView.topAnchor.constraint(equalTo: monthButtonCollectionView.bottomAnchor, constant: 10),
            categoryButtonCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryButtonCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            categoryButtonCollectionView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupMilestonesCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: view.frame.width - 32, height: 100)

        milestonesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        milestonesCollectionView.backgroundColor = .clear
        milestonesCollectionView.showsVerticalScrollIndicator = false
        milestonesCollectionView.dataSource = self
        milestonesCollectionView.delegate = self
        milestonesCollectionView.register(
            MilestoneCardCell.self,
            forCellWithReuseIdentifier: MilestoneCardCell.identifier
        )

        view.addSubview(milestonesCollectionView)
        milestonesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            milestonesCollectionView.topAnchor.constraint(equalTo: categoryButtonCollectionView.bottomAnchor, constant: 20),
            milestonesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            milestonesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            milestonesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }
    
    @IBAction func segmentedControlSwitched(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            showMilestonesView()
        case 1:
            showBodyMeasurementsView()
        default:
            showMilestonesView()
        }
    }
    
    private func showMilestonesView() {
        monthButtonCollectionView.isHidden = false
        categoryButtonCollectionView.isHidden = false
        milestonesCollectionView.isHidden = false
        bodyMeasurementCollectionView.isHidden = true
    }

    private func showBodyMeasurementsView() {
        monthButtonCollectionView.isHidden = true
        categoryButtonCollectionView.isHidden = true
        milestonesCollectionView.isHidden = true
        bodyMeasurementCollectionView.isHidden = false
        bodyMeasurementCollectionView.reloadData()
    }
    
    private func filterMilestones(month: String, category: String) {
        guard baby != nil else { return }

        let monthNumber = Int(month.components(separatedBy: " ").first ?? "") ?? 0
        let categoryLowercased = category.lowercased()

        filteredMilestones = dataController.milestones.filter { milestone in
            milestone.milestoneMonth.rawValue == monthNumber &&
            milestone.category.rawValue == categoryLowercased
        }

        milestonesCollectionView.reloadData()
    }
    
    // Called by delegate when overview is updated
    func milestonesOverviewDidUpdate() {
        milestonesCollectionView.reloadData()
    }
}

extension GrowTrackViewController: ButtonsCollectionViewDelegate {
    func didSelectButton(withTitle title: String, inCollection collection: ButtonsCollectionView) {
        guard
            let selectedMonthIndex = monthButtonCollectionView.selectedIndex,
            let selectedCategoryIndex = categoryButtonCollectionView.selectedIndex
        else { return }

        let selectedMonth = monthButtonTitles[selectedMonthIndex]
        let selectedCategory = categoryButtonTitles[selectedCategoryIndex]

        if collection == monthButtonCollectionView {
            filterMilestones(month: title, category: selectedCategory)
        } else if collection == categoryButtonCollectionView {
            filterMilestones(month: selectedMonth, category: title)
        }
    }
}

extension GrowTrackViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case bodyMeasurementCollectionView:
            return min(bodyMeasurements.count, 3)
        case milestonesCollectionView:
            return filteredMilestones.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == bodyMeasurementCollectionView {
            guard indexPath.row < bodyMeasurements.count else {
                assertionFailure("Index out of bounds for bodyMeasurements at row \(indexPath.row)")
                return UICollectionViewCell()
            }

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BodyMeasurementCollectionViewCell.identifier,
                for: indexPath
            ) as? BodyMeasurementCollectionViewCell else {
                return UICollectionViewCell()
            }

            configureMeasurementCell(cell, at: indexPath.row)
            return cell

        } else if collectionView == milestonesCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MilestoneCardCell.identifier,
                for: indexPath
            ) as? MilestoneCardCell else {
                return UICollectionViewCell()
            }

            cell.configure(with: filteredMilestones[indexPath.row])
            return cell
        }

        return UICollectionViewCell()
    }

    private func configureMeasurementCell(_ cell: BodyMeasurementCollectionViewCell, at index: Int) {
        let measurementType = bodyMeasurements[index]

        let units = ["cm", "kg", "cm"]
        let titleColors: [UIColor] = [
            UIColor(hex: "942192") ?? .systemPurple,
            UIColor(hex: "F27200") ?? .systemOrange,
            UIColor(hex: "AA7942") ?? .systemBrown
        ]

        let unit = index < units.count ? units[index] : ""
        let titleColor = titleColors[index % titleColors.count]

        var latestMeasurement = "0"
        var latestDate: Date?

        if let baby = baby {
            let measurements: [BabyMeasurement]

            switch measurementType {
            case "Height":
                measurements = baby.heightMeasurements
            case "Weight":
                measurements = baby.weightMeasurements
            case "Head Circumference":
                measurements = baby.headCircumferenceMeasurements
            default:
                measurements = []
            }

            if let latest = measurements.sorted(by: { $0.date < $1.date }).last {
                latestMeasurement = String(format: "%.2f", latest.value)
                latestDate = latest.date
            }
        }

        cell.titleLabel.text = measurementType
        cell.measurementUnitLabel.text = unit
        cell.measurementNumberLabel.text = latestMeasurement
        cell.labelImage.image = UIImage(systemName: "figure.arms.open")
        cell.labelImage.tintColor = titleColor
        cell.titleLabel.textColor = titleColor

        if let date = latestDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            cell.dateTimeLabel.text = formatter.string(from: date)
        } else {
            cell.dateTimeLabel.text = nil
        }
    }
}

extension GrowTrackViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == milestonesCollectionView {
            handleMilestoneSelection(at: indexPath)
        } else if collectionView == bodyMeasurementCollectionView {
            handleMeasurementSelection(at: indexPath)
        }
    }

    private func handleMilestoneSelection(at indexPath: IndexPath) {
        guard let baby = baby else { return }
        var milestone = filteredMilestones[indexPath.row]

        guard !milestone.isAchieved else { return }

        let modalVC = MilestoneModalViewController(
            category: milestone.category.rawValue,
            title: milestone.title,
            description: milestone.description,
            milestone: milestone
        )
        modalVC.baby = baby

        modalVC.onSave = { [weak self] date, image, videoURL, caption in
            guard let self = self else { return }

            self.dataController.updateMilestonesAchieved(
                &milestone, for: baby,
                date: date,
                image: image,
                video: videoURL,
                caption: caption
            )

            // Reflect updated milestone in filtered array
            self.filteredMilestones[indexPath.row] = milestone

            self.dataController.saveMedia(for: milestone, image: image, videoURL: videoURL, caption: caption)

            // Update Milestone Overview screen if it's already in nav stack
            if let milestonesVC = self.navigationController?.viewControllers
                .compactMap({ $0 as? MilestonesOverviewViewController }).first {
                milestonesVC.reloadMilestones()
                milestonesVC.delegate?.milestonesOverviewDidUpdate()
            }

            self.filterMilestones(
                month: self.monthButtonTitles[self.monthButtonCollectionView.selectedIndex ?? 0],
                category: self.categoryButtonTitles[self.categoryButtonCollectionView.selectedIndex ?? 0]
            )

            self.milestonesCollectionView.reloadData()

            modalVC.dismiss(animated: true) {
                self.showCongratulationsAlert()
            }
        }

        configureModalSheet(for: modalVC)
        present(modalVC, animated: true)
    }

    private func handleMeasurementSelection(at indexPath: IndexPath) {
        let selectedMeasurement = bodyMeasurements[indexPath.row]
        let type = selectedMeasurement == "Head Circumference" ? "head_circumference" : selectedMeasurement.lowercased()

        let storyboard = UIStoryboard(name: "GrowTrack", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "MeasurementDetailsViewController")
                as? MeasurementDetailsViewController else { return }

        vc.measurementType = selectedMeasurement
        vc.measurements = dataController.measurements.filter { $0.measurement_type == type }
        
        vc.onDataChanged = { [weak self] in
            guard let self = self, let baby = self.baby else { return }
            self.dataController.loadMeasurements(for: baby.babyID) {
                DispatchQueue.main.async {
                    self.bodyMeasurementCollectionView.reloadData()
                }
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func configureModalSheet(for modalVC: UIViewController) {
        modalVC.modalPresentationStyle = .pageSheet
        if let sheet = modalVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .large
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
        }
    }

    private func showCongratulationsAlert() {
        let alert = UIAlertController(
            title: "🎉 Congratulations 🎉",
            message: "The milestone has been marked as reached.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
