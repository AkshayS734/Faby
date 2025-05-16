import UIKit
import AVKit

class SpecialMomentsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var specialMomentTitle: UILabel!
    @IBOutlet weak var specialMomentDate: UILabel!
    @IBOutlet weak var mediaContainerView: UIView!
    private var currentMilestone: GrowthMilestone?
    private var specialMomentsImage: UIImageView?
    private var playerViewController: AVPlayerViewController?
    private var shimmerView: ShimmerView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        mediaContainerView.layer.cornerRadius = 10
        mediaContainerView.clipsToBounds = true
        mediaContainerView.isHidden = true
        
        specialMomentTitle.numberOfLines = 0
        specialMomentTitle.translatesAutoresizingMaskIntoConstraints = false
        specialMomentDate.numberOfLines = 0
        specialMomentDate.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        mediaContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mediaContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mediaContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            mediaContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            mediaContainerView.heightAnchor.constraint(equalToConstant: 150),
            
            specialMomentTitle.topAnchor.constraint(equalTo: mediaContainerView.bottomAnchor, constant: 5),
            specialMomentTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            specialMomentTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            specialMomentDate.topAnchor.constraint(equalTo: specialMomentTitle.bottomAnchor, constant: 3),
            specialMomentDate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            specialMomentDate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    func configure(with milestone: GrowthMilestone) {
        currentMilestone = milestone
        specialMomentTitle.text = milestone.caption ?? milestone.title

        if let achievedDate = milestone.achievedDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM yyyy"
            formatter.locale = Locale(identifier: "en_US")
            specialMomentDate.text = formatter.string(from: achievedDate)
        } else {
            specialMomentDate.text = "Date unknown"
        }

        showShimmer()

        var mediaLoaded = false

        if let videoURL = milestone.fetchedVideoURL {
            mediaLoaded = true
            removeShimmer()
            showVideoPlayer(with: videoURL)
        } else if let image = milestone.fetchedImage {
            mediaLoaded = true
            removeShimmer()
            showImageView(with: image)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self = self else { return }
            if !mediaLoaded {
                self.fallbackToImage()
            }
        }
    }
    func fallbackToImage() {
        guard let milestone = currentMilestone else {
            print("⚠️ No milestone available for fallback.")
            return
        }

        removeShimmer()

        if let defaultImage = UIImage(named: milestone.image) {
            showImageView(with: defaultImage)
        } else {
            print("❌ No fallback image available for milestone: \(milestone.id)")
        }
    }
    func showShimmer() {
        removeShimmer()

        let shimmer = ShimmerView(frame: mediaContainerView.bounds)
        shimmer.translatesAutoresizingMaskIntoConstraints = false
        mediaContainerView.addSubview(shimmer)

        NSLayoutConstraint.activate([
            shimmer.leadingAnchor.constraint(equalTo: mediaContainerView.leadingAnchor),
            shimmer.trailingAnchor.constraint(equalTo: mediaContainerView.trailingAnchor),
            shimmer.topAnchor.constraint(equalTo: mediaContainerView.topAnchor),
            shimmer.bottomAnchor.constraint(equalTo: mediaContainerView.bottomAnchor)
        ])

        shimmerView = shimmer
    }

    func removeShimmer() {
        shimmerView?.removeFromSuperview()
        shimmerView = nil
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        specialMomentsImage?.removeFromSuperview()
        playerViewController?.view.removeFromSuperview()
        removeShimmer()
        mediaContainerView.isHidden = true
        specialMomentTitle.text = nil
        specialMomentDate.text = nil
    }
    private func showImageView(with image: UIImage?) {
        specialMomentsImage?.removeFromSuperview()
        specialMomentsImage = UIImageView(image: image)
        guard let specialMomentsImage = specialMomentsImage else { return }
        
        specialMomentsImage.layer.cornerRadius = 10
        specialMomentsImage.clipsToBounds = true
        specialMomentsImage.contentMode = .scaleAspectFill
        specialMomentsImage.translatesAutoresizingMaskIntoConstraints = false
        
        mediaContainerView.addSubview(specialMomentsImage)
        
        NSLayoutConstraint.activate([
            specialMomentsImage.topAnchor.constraint(equalTo: mediaContainerView.topAnchor),
            specialMomentsImage.leadingAnchor.constraint(equalTo: mediaContainerView.leadingAnchor),
            specialMomentsImage.trailingAnchor.constraint(equalTo: mediaContainerView.trailingAnchor),
            specialMomentsImage.bottomAnchor.constraint(equalTo: mediaContainerView.bottomAnchor)
        ])
        
        mediaContainerView.isHidden = false
    }
    
    private func showVideoPlayer(with url: URL) {
        playerViewController?.view.removeFromSuperview()
        playerViewController = AVPlayerViewController()
        
        guard let playerViewController = playerViewController else { return }
        
        let player = AVPlayer(url: url)
        playerViewController.player = player
        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        playerViewController.view.layer.cornerRadius = 10
        playerViewController.view.clipsToBounds = true
        playerViewController.allowsPictureInPicturePlayback = true
        playerViewController.entersFullScreenWhenPlaybackBegins = true
        
        mediaContainerView.addSubview(playerViewController.view)
        
        NSLayoutConstraint.activate([
            playerViewController.view.topAnchor.constraint(equalTo: mediaContainerView.topAnchor),
            playerViewController.view.leadingAnchor.constraint(equalTo: mediaContainerView.leadingAnchor),
            playerViewController.view.trailingAnchor.constraint(equalTo: mediaContainerView.trailingAnchor),
            playerViewController.view.bottomAnchor.constraint(equalTo: mediaContainerView.bottomAnchor)
        ])
        player.isMuted = true
        player.play()
        
        mediaContainerView.isHidden = false
    }
}
