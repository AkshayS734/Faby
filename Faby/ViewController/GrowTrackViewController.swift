import UIKit

class GrowTrackViewController: UIViewController, HorizontalButtonCollectionViewDelegate{
    
    @IBOutlet weak var milestoneGrowthSegmentedControl: UISegmentedControl!
    private let monthButtonTitles = ["12 months", "15 months", "18 months", "24 months", "30 months", "36 months"]
    private let monthButtonSize = CGSize(width: 90, height: 100)
    private var monthHorizontalCollectionView: HorizontalButtonCollectionView!
    private let categoryButtonTitles = ["Social","Cognitive","Physical","Language"]
    private let categoryButtonSize = CGSize(width: 100, height: 40)
    private var categoryHorizontalCollectionView: HorizontalButtonCollectionView!
    private var milestoneCollectionView: UICollectionView!
    private var filteredMilestones: [GrowthMilestone] = []
    private var selectedCategory: String?
    private var selectedMonth: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        monthHorizontalCollectionView = HorizontalButtonCollectionView(buttonTitles: monthButtonTitles, buttonSize: monthButtonSize, minimumLineSpacing: 20, cornerRadius: 10)
        monthHorizontalCollectionView.buttonDelegate = self
        monthHorizontalCollectionView.updateData(monthButtonTitles)
        setupMonthCollectionView()
        
        categoryHorizontalCollectionView = HorizontalButtonCollectionView(buttonTitles: categoryButtonTitles, buttonSize: categoryButtonSize,  minimumLineSpacing: 10, cornerRadius: 7)
        categoryHorizontalCollectionView.buttonDelegate = self
        categoryHorizontalCollectionView.updateData(categoryButtonTitles)
        setupCategoryCollectionView()
        setupMilestoneCollectionView()
        
    }
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if milestoneGrowthSegmentedControl.selectedSegmentIndex == 0 {
            monthHorizontalCollectionView.isHidden = false
            categoryHorizontalCollectionView.isHidden = false
            milestoneCollectionView.isHidden = false
        } else {
            monthHorizontalCollectionView.isHidden = true
            categoryHorizontalCollectionView.isHidden = true
            milestoneCollectionView.isHidden = true
        }
    }
    func didSelectButton(at index: Int) {
        if categoryHorizontalCollectionView.isHidden == false {
            selectedCategory = categoryButtonTitles[index]
        } else {
            selectedMonth = monthButtonTitles[index]
        }
        filterMilestones()
    }
    private func setupMonthCollectionView() {
        view.addSubview(monthHorizontalCollectionView)
        monthHorizontalCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            monthHorizontalCollectionView.topAnchor.constraint(equalTo: milestoneGrowthSegmentedControl.bottomAnchor, constant: 20),
            monthHorizontalCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            monthHorizontalCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            monthHorizontalCollectionView.heightAnchor.constraint(equalToConstant: 100)
            
        ])
    }
    
    private func setupCategoryCollectionView() {
        view.addSubview(categoryHorizontalCollectionView)
        categoryHorizontalCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryHorizontalCollectionView.topAnchor.constraint(equalTo: monthHorizontalCollectionView.bottomAnchor, constant: 0),
            categoryHorizontalCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryHorizontalCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryHorizontalCollectionView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    private func setupMilestoneCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        milestoneCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        milestoneCollectionView.register(MilestoneQueryCell.self, forCellWithReuseIdentifier: MilestoneQueryCell.identifier)
        milestoneCollectionView.delegate = self
        milestoneCollectionView.dataSource = self
        milestoneCollectionView.backgroundColor = .white
            
        view.addSubview(milestoneCollectionView)
        milestoneCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            milestoneCollectionView.topAnchor.constraint(equalTo: categoryHorizontalCollectionView.bottomAnchor, constant: 20),
            milestoneCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            milestoneCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            milestoneCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
        
    private func filterMilestones() {
        if let selectedCategory = selectedCategory, let selectedMonthString = selectedMonth {
                if let selectedMonth = monthFromString(selectedMonthString), let categoryEnum = categoryFromString(selectedCategory) {
                    filteredMilestones = GrowthMilestonesDataModel.shared.milestones(forCategory: categoryEnum, andMonth: selectedMonth)
                }
        }
        else if let selectedCategory = selectedCategory {
            if let categoryEnum = categoryFromString(selectedCategory) {
                filteredMilestones = GrowthMilestonesDataModel.shared.milestones(forCategory: categoryEnum)
            }
        }
            // If only month is selected
        else if let selectedMonthString = selectedMonth {
            if let selectedMonth = monthFromString(selectedMonthString) {
                filteredMilestones = GrowthMilestonesDataModel.shared.milestones(forMonth: selectedMonth)
            }
        }
        else {
            filteredMilestones = GrowthMilestonesDataModel.shared.milestones
        }
        milestoneCollectionView.reloadData()
    }
    func categoryFromString(_ categoryString: String) -> GrowthCategory? {
        switch categoryString.lowercased() {
        case "cognitive":
            return .cognitive
        case "social":
            return .social
        case "physical":
            return .physical
        case "language":
            return .language
        default:
            return nil
        }
    }
    func monthFromString(_ monthString: String) -> MilestoneMonth? {
        switch monthString.lowercased() {
        case "12 months":
            return .month12
        case "15 months":
            return .month15
        case "18 months":
            return .month18
        case "24 months":
            return .month24
        case "30 months":
            return .month30
        case "36 months":
            return .month36
        default:
            return nil
        }
    }

}



extension GrowTrackViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredMilestones.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MilestoneQueryCell.identifier, for: indexPath) as? MilestoneQueryCell else {
            return UICollectionViewCell()
        }
        
        let milestone = filteredMilestones[indexPath.item]
        cell.configure(with: milestone)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle the cell tap, navigate or perform action
    }
}
