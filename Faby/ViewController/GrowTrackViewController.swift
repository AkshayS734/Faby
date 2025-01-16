import UIKit

class GrowTrackViewController: UIViewController{


    @IBOutlet weak var milestoneGrowthSegmentedControl: UISegmentedControl!
    private let monthButtonTitles = ["12 months", "15 months", "18 months", "24 months", "30 months", "36 months"]
    private let monthButtonSize = CGSize(width: 90, height: 100)
    private var monthHorizontalCollectionView: HorizontalButtonCollectionView!
    private let categoryButtonTitles = ["Social","Cognitive","Physical","Language"]
    private let categoryButtonSize = CGSize(width: 100, height: 40)
    private var categoryHorizontalCollectionView: HorizontalButtonCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        monthHorizontalCollectionView = HorizontalButtonCollectionView(buttonTitles: monthButtonTitles, buttonSize: monthButtonSize, minimumLineSpacing: 20, cornerRadius: 10)
        monthHorizontalCollectionView.updateData(monthButtonTitles)
        setupMonthCollectionView()
        
        categoryHorizontalCollectionView = HorizontalButtonCollectionView(buttonTitles: categoryButtonTitles, buttonSize: categoryButtonSize,  minimumLineSpacing: 10, cornerRadius: 7)
        categoryHorizontalCollectionView.updateData(categoryButtonTitles)
        setupCategoryCollectionView()
        
    }
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if milestoneGrowthSegmentedControl.selectedSegmentIndex == 0 {
            monthHorizontalCollectionView.isHidden = false
            categoryHorizontalCollectionView.isHidden = false
        } else {
            monthHorizontalCollectionView.isHidden = true
            categoryHorizontalCollectionView.isHidden = true
        }
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
}
