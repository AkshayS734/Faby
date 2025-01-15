import UIKit

class GrowTrackViewController: UIViewController{


    @IBOutlet weak var milestoneGrowthSegmentedControl: UISegmentedControl!
    private var horizontalCollectionView: HorizontalButtonCollectionView!
    private let buttonTitles = ["12 months", "15 months", "18 months", "24 months", "30 months", "36 months"]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        
        horizontalCollectionView = HorizontalButtonCollectionView(buttonTitles: buttonTitles)
        view.addSubview(horizontalCollectionView)
        horizontalCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            horizontalCollectionView.topAnchor.constraint(equalTo: milestoneGrowthSegmentedControl.bottomAnchor, constant: 20),
            horizontalCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            horizontalCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            horizontalCollectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    
}
