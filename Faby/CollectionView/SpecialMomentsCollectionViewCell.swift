import UIKit
import AVKit

class SpecialMomentsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var specialMomentTitle: UILabel!
    @IBOutlet weak var specialMomentDate: UILabel!
    @IBOutlet weak var specialMomentsImage: UIImageView!
    @IBOutlet weak var playerContainerView: UIView!
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupImageConstraints()
    }
    
    private func setupUI() {
        specialMomentsImage.layer.cornerRadius = 10
        specialMomentsImage.clipsToBounds = true
        specialMomentsImage.contentMode = .scaleToFill
        playerContainerView.isHidden = true
    }
    
    private func setupImageConstraints() {
        specialMomentsImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            specialMomentsImage.widthAnchor.constraint(equalToConstant: 201),
            specialMomentsImage.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    func configure(with milestone: (GrowthMilestone, Date)) {
        let (milestoneDetail, achievedDate) = milestone
        
        // Set the title and date
        specialMomentTitle.text = milestoneDetail.caption ?? milestoneDetail.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        specialMomentDate.text = dateFormatter.string(from: achievedDate)
        
        // Show video or image depending on the type of media
        if let videoPath = milestoneDetail.userVideoPath, !videoPath.isEmpty {
            showVideoPlayer(with: URL(fileURLWithPath: videoPath))
        } else if let userImagePath = milestoneDetail.userImagePath, !userImagePath.isEmpty {
            specialMomentsImage.image = UIImage(contentsOfFile: userImagePath)
            specialMomentsImage.isHidden = false
            playerContainerView.isHidden = true
        } else {
            specialMomentsImage.image = UIImage(named: milestoneDetail.image)
            specialMomentsImage.isHidden = false
            playerContainerView.isHidden = true
        }
    }
    
    private func showVideoPlayer(with url: URL) {
        // Remove previous player if exists
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        
        // Create and setup the player
        player = AVPlayer(url: url)
        
        // Ensure that the player is not nil before proceeding
        guard let player = player else { return }
        
        // Create an AVPlayerLayer to show the video
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = playerContainerView.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        playerContainerView.layer.addSublayer(playerLayer!)
        
        // Play the video
        player.play()
        
        // Hide the image and show the player container view
        specialMomentsImage.isHidden = true
        playerContainerView.isHidden = false
    }
}
