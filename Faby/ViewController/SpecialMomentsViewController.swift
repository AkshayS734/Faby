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
    
    private let emptyStateCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "special_moments")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No growth added yet"
        label.textColor = UIColor(hex: "#333333")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupUI()
        populateMilestones()
        
        // Add content inset to maintain proper spacing
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(emptyStateCardView)
        
        emptyStateCardView.addSubview(emptyStateImageView)
        emptyStateCardView.addSubview(emptyLabel)

        // Add tap gesture to the entire card
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
        emptyStateCardView.addGestureRecognizer(tapGesture)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            emptyStateCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyStateCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emptyStateCardView.heightAnchor.constraint(equalToConstant: 225),
            emptyStateCardView.topAnchor.constraint(equalTo: view.topAnchor),
            
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateCardView.centerXAnchor),
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateCardView.topAnchor, constant: 30),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyLabel.leadingAnchor.constraint(equalTo: emptyStateCardView.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(equalTo: emptyStateCardView.trailingAnchor, constant: -16)
        ])
    }

    @objc private func handleCardTap() {
        // Handle the tap action here - this will be called both when tapping the card or the button
        // You can implement the navigation to add memory screen here
    }

    func populateMilestones() {
        milestones = baby.milestonesAchieved.filter { (milestone, _) in
            guard let imagePath = milestone.userImagePath else { return false }
            return !imagePath.isEmpty
        }
        if milestones.isEmpty {
            emptyStateCardView.isHidden = false
            collectionView.isHidden = true
        } else {
            emptyStateCardView.isHidden = true
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
