import UIKit

class cardDetailsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set a uniform corner radius for both imageView and stackView
      //  let cornerRadius: CGFloat = 10
        
        // Corner radius for the image view
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.alpha = 1.0
        // Corner radius for the stack view
        stackView.layer.cornerRadius = 20
        stackView.clipsToBounds = true
        
        // Add the overlay effect to the stack view
        applyBlurredBackgroundEffect()

        // Set font and text color
        title.font = UIFont.systemFont(ofSize: 16)
       // title.font = UIFont.boldSystemFont(ofSize: 16)
       // title.textColor = .white // Ensure title is visible with good contrast
    }
    
    func configure(with topic: Topics) {
        title.text = topic.title
        subtitle.text = topic.subtitle
        
        // Set the image dynamically
//        if let image = UIImage(named: topic.imageView) {
//            imageView.image = image.withRenderingMode(.alwaysOriginal)
//        }
    }

    // Apply blur effect on stack view's background
    private func applyBlurredBackgroundEffect() {
        // Create a blur effect and a visual effect view
        let blurEffect = UIBlurEffect(style: .light) // Adjust blur style if needed
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.alpha = 0.9
        // Add blur effect view behind the stack view
        contentView.insertSubview(blurEffectView, belowSubview: stackView)
        
        // Pin the blur effect view to the edges of the stack view
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: stackView.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        ])
        
        // Set the stack view's position and size relative to the image view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 110), // Top 70 points from the image
            stackView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor), // Leading edge aligned with image
            stackView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor), // Trailing edge aligned with image
            stackView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor) // Bottom aligned with image
        ])
    }
}
