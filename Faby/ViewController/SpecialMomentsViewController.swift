import UIKit

class SpecialMomentsViewController: UIViewController {
    var milestones: [(GrowthMilestone, Date)] = []
    var baby = BabyDataModel.shared.babyList[0]
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 225, height: 225)
        layout.minimumLineSpacing = 20

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .systemGray6
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "SpecialMomentsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SpecialMomentsCollectionViewCell")
        return collectionView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No Special Moments added yet"
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupUI()
        populateMilestones()
    }

    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func populateMilestones() {
        milestones = baby.milestonesAchieved.filter { (milestone, _) in
            return !(milestone.userImagePath?.isEmpty ?? true) || !(milestone.userVideoPath?.isEmpty ?? true)
        }
        if milestones.isEmpty {
            emptyLabel.isHidden = false
        } else {
            emptyLabel.isHidden = true
        }
        collectionView.reloadData()
    }
}

extension SpecialMomentsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return milestones.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpecialMomentsCollectionViewCell", for: indexPath) as? SpecialMomentsCollectionViewCell else {
            return UICollectionViewCell()
        }
        let milestone = milestones[indexPath.item]
        cell.configure(with: milestone)
        return cell
    }
}
