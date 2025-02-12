import UIKit

class GrowTrackViewController: UIViewController, MilestonesOverviewDelegate{
    
    var baby: Baby! = BabyDataModel.shared.babyList[0]
    
    @IBOutlet weak var topSegmentedControl: UISegmentedControl!
    
    @IBAction func showMilestoneOverviewTapped(_ sender: UIBarButtonItem) {
//        print("Button was tapped!")
        let milestonesVC = MilestonesOverviewViewController()
        milestonesVC.delegate = self
        navigationController?.pushViewController(milestonesVC, animated: true)
    }
    
    private var monthButtonCollectionView: ButtonsCollectionView!
    private var categoryButtonCollectionView: ButtonsCollectionView!
    private var milestonesCollectionView: UICollectionView!
    
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
    private var filteredMilestones: [GrowthMilestone] = []
    
    private var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Congratulations! Your child has reached all the milestones in this section."
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    @IBOutlet weak var bodyMeasurementCollectionView: UICollectionView!
    private let bodyMeasurements = ["Height", "Weight", "Head Circumference"]
    let units = ["cm", "kg", "cm"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        if let baby = BabyDataModel.shared.babyList.first {
            baby.measurementUpdated = { [weak self] in
                self?.bodyMeasurementCollectionView.reloadData()
            }
        }
        let button = UIBarButtonItem(image: UIImage(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(showMilestoneOverviewTapped))
        self.navigationItem.rightBarButtonItem = button
        navigationItem.rightBarButtonItem = button
        
        view.addSubview(emptyLabel)

        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
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
        
        setupMilestonesCollectionView()
        monthButtonCollectionView.selectButton(at: 0)
        categoryButtonCollectionView.selectButton(at: 0)
        filterMilestones(month: monthButtonTitles[0], category: categoryButtonTitles[0])
        
        let nib = UINib(nibName: "BodyMeasurementCollectionViewCell", bundle: nil)
        bodyMeasurementCollectionView.register(nib, forCellWithReuseIdentifier: "BodyMeasurementCollectionViewCell")
        
        bodyMeasurementCollectionView.dataSource = self
        bodyMeasurementCollectionView.delegate = self
        bodyMeasurementCollectionView.isHidden = true
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: view.frame.width - 32, height: 150)
        bodyMeasurementCollectionView.collectionViewLayout = layout
        bodyMeasurementCollectionView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
    }
    private func setupMonthCollectionView() {
        monthButtonCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            monthButtonCollectionView.topAnchor.constraint(equalTo: topSegmentedControl.bottomAnchor, constant: 20),
            monthButtonCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            monthButtonCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            monthButtonCollectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    private func setupCategoryCollectionView() {
        categoryButtonCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryButtonCollectionView.topAnchor.constraint(equalTo: monthButtonCollectionView.bottomAnchor, constant: 10),
            categoryButtonCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryButtonCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
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
        milestonesCollectionView.register(MilestoneCardCell.self, forCellWithReuseIdentifier: MilestoneCardCell.identifier)
        milestonesCollectionView.dataSource = self
        milestonesCollectionView.delegate = self
        milestonesCollectionView.showsVerticalScrollIndicator = false
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
        
        let selectedIndex = sender.selectedSegmentIndex
        switch selectedIndex {
            case 0:
            monthButtonCollectionView.isHidden = false
            categoryButtonCollectionView.isHidden = false
            milestonesCollectionView.isHidden = false
            bodyMeasurementCollectionView.isHidden = true
            bodyMeasurementCollectionView.reloadData()
            emptyLabel.isHidden = !filteredMilestones.isEmpty
            case 1:
            monthButtonCollectionView.isHidden = true
            categoryButtonCollectionView.isHidden = true
            milestonesCollectionView.isHidden = true
            bodyMeasurementCollectionView.isHidden = false
            bodyMeasurementCollectionView.reloadData()
            emptyLabel.isHidden = true
            default:
            monthButtonCollectionView.isHidden = false
            categoryButtonCollectionView.isHidden = false
            milestonesCollectionView.isHidden = false
            bodyMeasurementCollectionView.isHidden = true
            bodyMeasurementCollectionView.reloadData()
            emptyLabel.isHidden = !filteredMilestones.isEmpty
            
        }
    }
    private func filterMilestones(month: String, category: String) {
        guard let selectedBaby = BabyDataModel.shared.babyList.first else { return }
        let monthNumber = Int(month.split(separator: " ")[0]) ?? 0
            
        filteredMilestones = selectedBaby.milestones.filter { milestone in
            let isMatchingMonth = milestone.milestoneMonth.rawValue == monthNumber
            let isMatchingCategory = milestone.category.rawValue == category.lowercased()
            return isMatchingMonth && isMatchingCategory
        }
        emptyLabel.isHidden = !filteredMilestones.isEmpty
        
        milestonesCollectionView.reloadData()
    }
    func milestonesOverviewDidUpdate() {
        milestonesCollectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMeasurementDetail",
           let destinationVC = segue.destination as? MeasurementDetailsViewController,
           let measurementType = sender as? String {
            destinationVC.measurementType = measurementType
        }
    }
}


extension GrowTrackViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == milestonesCollectionView {
            guard let selectedBaby = BabyDataModel.shared.babyList.first else { return }
            let selectedMilestone = filteredMilestones[indexPath.row]
            
            // Prevent navigation if milestone is already achieved
            if selectedMilestone.isAchieved {
                return
            }
                    
            let modalVC = MilestoneModalViewController(
                category: selectedMilestone.category.rawValue,
                title: selectedMilestone.title,
                description: selectedMilestone.description,
                milestone: selectedMilestone
            )
            modalVC.baby = baby
            modalVC.onSave = { [weak self] date, image, videoURL, caption in
                guard let self = self else { return }
                
                selectedBaby.updateMilestonesAchieved(selectedMilestone, date: date)
                
                if let milestonesVC = self.navigationController?.viewControllers.first(where: { $0 is MilestonesOverviewViewController }) as? MilestonesOverviewViewController {
                    milestonesVC.reloadMilestones()
                    milestonesVC.delegate?.milestonesOverviewDidUpdate()
                }
                
                self.filterMilestones(
                    month: self.monthButtonTitles[self.monthButtonCollectionView.selectedIndex ?? 0],
                    category: self.categoryButtonTitles[self.categoryButtonCollectionView.selectedIndex ?? 0]
                )
                if let image = image {
                    selectedBaby.saveMilestoneUserImage(for: selectedMilestone, image: image, caption: caption)
                }
                if let videoURL = videoURL {
                    selectedBaby.saveMilestoneUserVideo(for: selectedMilestone, videoURL: videoURL, caption: caption)
                }
                self.milestonesCollectionView.reloadData()
                
                modalVC.dismiss(animated: true) {
                    self.showCongratulationsAlert()
                }
            }
            modalVC.modalPresentationStyle = .formSheet
            present(modalVC, animated: true, completion: nil)
        } else if collectionView == bodyMeasurementCollectionView {
            let titles = ["Height", "Weight", "Head Circumference"]
            let selectedMeasurement = titles[indexPath.row]

            performSegue(withIdentifier: "showMeasurementDetail", sender: selectedMeasurement)
        }
        
    }
    private func showCongratulationsAlert() {
        let alertController = UIAlertController(
            title: "🎉 Congratulations 🎉",
            message: "The milestone has been marked as reached.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        if Scanner(string: hexSanitized).scanHexInt64(&rgb) {
            let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgb & 0x0000FF) / 255.0
            self.init(red: red, green: green, blue: blue, alpha: 1.0)
        } else {
            self.init(red: 0, green: 0, blue: 0, alpha: 1.0)
        }
    }
}

extension GrowTrackViewController: ButtonsCollectionViewDelegate {
    func didSelectButton(withTitle title: String, inCollection collection: ButtonsCollectionView) {
        if collection == monthButtonCollectionView {
            filterMilestones(month: title, category: categoryButtonTitles[categoryButtonCollectionView.selectedIndex ?? 0])
        } else if collection == categoryButtonCollectionView {
            filterMilestones(month: monthButtonTitles[monthButtonCollectionView.selectedIndex ?? 0], category: title)
        }
    }
}
extension GrowTrackViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == bodyMeasurementCollectionView {
            return 3
        } else if collectionView == milestonesCollectionView{
            return filteredMilestones.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == bodyMeasurementCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "BodyMeasurementCollectionViewCell",
                for: indexPath
            ) as! BodyMeasurementCollectionViewCell
            let units = ["cm", "kg", "cm"]
            let measurementType = bodyMeasurements[indexPath.row]
            let unit = units[indexPath.row]
            let titleColors: [UIColor] = [
                UIColor(hex: "942192"),
                UIColor(hex: "F27200"),
                UIColor(hex: "AA7942")
            ]
            
            if let baby = BabyDataModel.shared.babyList.first {
                let latestMeasurement: String
                let latestDate: Date?
                    
                switch measurementType {
                case "Height":
                    if let latest = baby.height.max(by: { $0.key < $1.key }) {
                        latestMeasurement = String(format: "%.2f", latest.key)
                        latestDate = latest.value
                    } else {
                        latestMeasurement = "0"
                        latestDate = nil
                    }
                case "Weight":
                    if let latest = baby.weight.max(by: { $0.key < $1.key }) {
                        latestMeasurement = String(format: "%.2f", latest.key)
                        latestDate = latest.value
                    } else {
                        latestMeasurement = "0"
                        latestDate = nil
                    }
                case "Head Circumference":
                    if let latest = baby.headCircumference.max(by: { $0.key < $1.key }) {
                        latestMeasurement = String(format: "%.2f", latest.key)
                        latestDate = latest.value
                    } else {
                        latestMeasurement = "0"
                        latestDate = nil
                    }
                default:
                    latestMeasurement = "0"
                    latestDate = nil
                }

                cell.measurementNumberLabel.text = latestMeasurement
                if let date = latestDate {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    cell.dateTimeLabel.text = dateFormatter.string(from: date)
                } else {
                    cell.dateTimeLabel.text = nil
                }
            } else {
                cell.measurementNumberLabel.text = "0"
                cell.dateTimeLabel.text = nil
            }

            cell.titleLabel.text = measurementType
            cell.labelImage.image = UIImage(systemName: "figure.arms.open")
            cell.labelImage.tintColor = titleColors[indexPath.row % titleColors.count]
            cell.titleLabel.textColor = titleColors[indexPath.row % titleColors.count]
            cell.measurementUnitLabel.text = unit
            return cell
        } else if collectionView == milestonesCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MilestoneCardCell.identifier,
                for: indexPath
            ) as! MilestoneCardCell
            cell.configure(with: filteredMilestones[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
}
