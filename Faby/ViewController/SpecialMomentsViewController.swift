import UIKit

class SpecialMomentsViewController: UIViewController {
    var milestones: [GrowthMilestone] = []
    var dataController: DataController {
        return DataController.shared
    }
    var baby: Baby?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 225, height: 200)
        layout.minimumLineSpacing = 15

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "SpecialMomentsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SpecialMomentsCollectionViewCell")
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
        return collectionView
    }()
    private let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "undraw_play-time_c8vl")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
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
        baby = dataController.baby/* ?? Baby(babyId: UUID(), name: "Default", dateOfBirth: "01012024", gender: .male)*/
        view.backgroundColor = .clear
        setupUI()
        populateMilestones()
    }

    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(emptyLabel)
        view.addSubview(emptyImageView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            emptyImageView.widthAnchor.constraint(equalToConstant: 175),
            emptyImageView.heightAnchor.constraint(equalToConstant: 175),

            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 16),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: collectionView)

        guard let indexPath = collectionView.indexPathForItem(at: location), gesture.state == .began else { return }

        let milestone = milestones[indexPath.item]
        let date = milestone.achievedDate ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateString = dateFormatter.string(from: date)
        let caption = "\(milestone.caption ?? milestone.title) on \(dateString)"

        var itemsToShare: [Any] = [caption]
        if let imagePath = milestone.userImagePath, !imagePath.isEmpty,
           let image = UIImage(contentsOfFile: imagePath) {
            itemsToShare.append(image)
        }
        if let videoPath = milestone.userVideoPath, !videoPath.isEmpty {
            let videoURL = URL(fileURLWithPath: videoPath)
            itemsToShare.append(videoURL)
        }
        let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        present(activityVC, animated: true)
    }

    func populateMilestones() {
        milestones = dataController.milestones.filter {
            $0.isAchieved && (
                !($0.userImagePath?.isEmpty ?? true) ||
                !($0.userVideoPath?.isEmpty ?? true)
            )
        }.sorted {
            ($0.achievedDate ?? Date.distantPast) > ($1.achievedDate ?? Date.distantPast)
        }

        for (index, milestone) in milestones.enumerated() {
            if let imagePath = milestone.userImagePath, !imagePath.isEmpty {
                if let cachedImage = ImageCache.shared.getImage(forKey: imagePath) {
                    milestone.fetchedImage = cachedImage
                } else {
                    SupabaseManager.shared.fetchMediaFromMilestoneBucket(path: imagePath, isImage: true) { media in
                        DispatchQueue.main.async {
                            if let image = media as? UIImage {
                                milestone.fetchedImage = image
                            }
                            self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                        }
                    }
                }
            } else if let videoPath = milestone.userVideoPath, !videoPath.isEmpty {
                if let cachedURL = VideoCache.shared.getVideoURL(forKey: videoPath) {
                    milestone.fetchedVideoURL = cachedURL
                } else {
                    SupabaseManager.shared.fetchMediaFromMilestoneBucket(path: videoPath, isImage: false) { media in
                        DispatchQueue.main.async {
                            if let url = media as? URL {
                                milestone.fetchedVideoURL = url
                            }
                            self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                        }
                    }
                }
            }
        }

        let isEmpty = milestones.isEmpty
        emptyLabel.isHidden = !isEmpty
        emptyImageView.isHidden = !isEmpty
        collectionView.reloadData()
    }
}

extension SpecialMomentsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("Count Special moments: \(milestones.count)")
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

//class SpecialMomentsViewController: UIViewController {
//    var milestones: [GrowthMilestone] = []
//    var dataController = DataController.shared
//    var baby : Baby?
//
//    private lazy var collectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.itemSize = CGSize(width: 225, height: 225)
//        layout.minimumLineSpacing = 15
//
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.backgroundColor = .systemGray6
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.register(UINib(nibName: "SpecialMomentsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SpecialMomentsCollectionViewCell")
//        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
//        collectionView.addGestureRecognizer(longPressGesture)
//        return collectionView
//    }()
//
//    private let emptyLabel: UILabel = {
//        let label = UILabel()
//        label.text = "No Special Moments added yet"
//        label.textColor = .darkGray
//        label.font = UIFont.systemFont(ofSize: 16)
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        baby = dataController.baby ?? Baby(babyId: UUID(), name: "Default", dateOfBirth: "01012024", gender: .male)
//        view.backgroundColor = .clear
//        setupUI()
//        populateMilestones()
//    }
//
//    private func setupUI() {
//        view.addSubview(collectionView)
//        view.addSubview(emptyLabel)
//
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor,constant: -16),
//            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
//        let location = gesture.location(in: collectionView)
//
//        guard let indexPath = collectionView.indexPathForItem(at: location), gesture.state == .began else { return }
//
//        let (milestone, date) = milestones[indexPath.item]
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .long
//        let dateString = dateFormatter.string(from: date)
//        let caption = "\(milestone.caption ?? milestone.title) on \(dateString)"
//
//        var itemsToShare: [Any] = [caption]
//        if let imagePath = milestone.userImagePath, !imagePath.isEmpty,
//           let image = UIImage(contentsOfFile: imagePath) {
//            itemsToShare.append(image)
//        }
//        if let videoPath = milestone.userVideoPath, !videoPath.isEmpty {
//            let videoURL = URL(fileURLWithPath: videoPath)
//            itemsToShare.append(videoURL)
//        }
//        let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
//        present(activityVC, animated: true)
//    }
//    func populateMilestones() {
//        milestones = dataController.milestones.filter {
//            $0.isAchieved && (
//                !($0.userImagePath?.isEmpty ?? true) ||
//                !($0.userVideoPath?.isEmpty ?? true)
//            )
//        }.sorted {
//            ($0.achievedDate ?? Date.distantPast) > ($1.achievedDate ?? Date.distantPast)
//        }
//
//        emptyLabel.isHidden = !milestones.isEmpty
//        collectionView.reloadData()
//    }
//}
//
//extension SpecialMomentsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return milestones.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpecialMomentsCollectionViewCell", for: indexPath) as? SpecialMomentsCollectionViewCell else {
//            return UICollectionViewCell()
//        }
//        let milestone = milestones[indexPath.item]
//        cell.configure(with: milestone)
//        return cell
//    }
//}
