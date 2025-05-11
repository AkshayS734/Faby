import UIKit

class TodayBiteCollectionViewCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.systemGray
        label.textAlignment = .left
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(timeLabel)

        NSLayoutConstraint.activate([
           
            
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 150),

           
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            
            
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }

    func configure(with bite: TodayBite) {
        titleLabel.text = bite.title
        timeLabel.text = bite.time
        
        // Set a placeholder image while loading
        imageView.image = UIImage(named: "placeholder") ?? UIImage(systemName: "photo")
        
        let imageName = bite.imageName
        
        // Handle different image source types
        if let image = UIImage(named: imageName) {
            // Local asset case
            imageView.image = image
        } else if imageName.hasPrefix("http://") || imageName.hasPrefix("https://") {
            // URL case - load asynchronously
            loadImageFromURL(imageUrl: imageName)
        } else if imageName.contains("/") {
            // Local file path case
            if let image = UIImage(contentsOfFile: imageName) {
                imageView.image = image
            }
        } else {
            // If none of the above worked, keep the placeholder
            imageView.image = UIImage(named: "placeholder") ?? UIImage(systemName: "photo")
        }
    }
    
    private func loadImageFromURL(imageUrl: String) {
        guard let url = URL(string: imageUrl) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  error == nil,
                  let data = data,
                  let image = UIImage(data: data) else {
                return
            }
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
        
        task.resume()
    }
}
