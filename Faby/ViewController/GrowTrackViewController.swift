import UIKit

class GrowTrackViewController: UIViewController{
    
    
    @IBOutlet weak var topSegmentedControl: UISegmentedControl!
    
    private var monthButtonCollectionView: ButtonsCollectionView!
    private var categoryButtonCollectionView: ButtonsCollectionView!
    private var milestonesCollectionView: UICollectionView!
    
    private let monthButtonTitles = ["12 months", "15 months", "18 months", "24 months", "30 months", "36 months"]
    private let monthButtonSize = CGSize(width: 90, height: 100)
    private let categoryButtonTitles = ["Cognitive", "Language", "Physical", "Social"]
    private let categoryButtonSize = CGSize(width: 90, height: 50)
    
    private var filteredMilestones: [GrowthMilestone] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        
        monthButtonCollectionView = ButtonsCollectionView(buttonTitles: monthButtonTitles, buttonSize: monthButtonSize, minimumLineSpacing: 5, cornerRadius: 10)
        monthButtonCollectionView.delegate = self
        view.addSubview(monthButtonCollectionView)
        setupMonthCollectionView()
        
        categoryButtonCollectionView = ButtonsCollectionView(buttonTitles: categoryButtonTitles, buttonSize: categoryButtonSize, minimumLineSpacing: 10, cornerRadius: 7)
        categoryButtonCollectionView.delegate = self
        view.addSubview(categoryButtonCollectionView)
        setupCategoryCollectionView()
        
        setupMilestonesCollectionView()
        monthButtonCollectionView.selectButton(at: 0)
        categoryButtonCollectionView.selectButton(at: 0)
        filterMilestones(month: monthButtonTitles[0], category: categoryButtonTitles[0])
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
            case 1:
            monthButtonCollectionView.isHidden = true
            categoryButtonCollectionView.isHidden = true
            milestonesCollectionView.isHidden = true
            default:
            monthButtonCollectionView.isHidden = false
            categoryButtonCollectionView.isHidden = false
            milestonesCollectionView.isHidden = false
            
        }
    }
    private func filterMilestones(month: String, category: String) {
        let monthNumber = Int(month.split(separator: " ")[0]) ?? 0
        filteredMilestones = GrowthMilestonesDataModel.shared.milestones.filter { milestone in
            let isMatchingMonth = milestone.milestoneMonth.rawValue == monthNumber
            let isMatchingCategory = milestone.category.rawValue == category.lowercased()
            return isMatchingMonth && isMatchingCategory
        }

//        print("Filtered milestones count: \(filteredMilestones.count)")
            // Reload the collection view after filtering
        milestonesCollectionView.reloadData()
    }
}


extension GrowTrackViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMilestone = filteredMilestones[indexPath.row]
        let modalVC = MilestoneModalViewController(
            category: selectedMilestone.category.rawValue,
            title: selectedMilestone.title,
            description: selectedMilestone.description
        )
        modalVC.onSave = { [weak self] date, image in
            // Handle the saved data here
            print("Milestone reached on \(date), image: \(image?.description ?? "No Image")")
        }
        modalVC.modalPresentationStyle = .formSheet
        present(modalVC, animated: true, completion: nil)
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
        return filteredMilestones.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MilestoneCardCell.identifier, for: indexPath) as! MilestoneCardCell
        cell.configure(with: filteredMilestones[indexPath.row])
        return cell
    }
}
