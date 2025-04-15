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
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "SpecialMomentsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SpecialMomentsCollectionViewCell")
        return collectionView
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Special")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No growth added yet"
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
        view.addSubview(emptyStateView)
        
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor),
            emptyStateView.heightAnchor.constraint(equalTo: view.heightAnchor),
            
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 150),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 150),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -16)
        ])
    }

    func populateMilestones() {
        milestones = baby.milestonesAchieved.filter { (milestone, _) in
            return !(milestone.userImagePath?.isEmpty ?? true) || !(milestone.userVideoPath?.isEmpty ?? true)
        }
        if milestones.isEmpty {
            emptyStateView.isHidden = false
            collectionView.isHidden = true
        } else {
            emptyStateView.isHidden = true
            collectionView.isHidden = false
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
