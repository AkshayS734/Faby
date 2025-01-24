import UIKit

class ButtonCollectionViewCell: UICollectionViewCell {
    static let identifier = "ButtonCollectionViewCell"
    
    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 11
        button.clipsToBounds = true
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        return imageView
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "months"
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
            
        button.addSubview(imageView)
        button.addSubview(numberLabel)
        button.addSubview(monthLabel)
        button.addSubview(titleLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            
            imageView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 5),
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20),
            
            numberLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor, constant: -10),
            
            monthLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            monthLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 5),
            
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -5),
            titleLabel.topAnchor.constraint(equalTo: button.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: button.bottomAnchor)
        ])
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func configureCategoryButton(with title: String, image: UIImage?) {
        titleLabel.text = title
        imageView.image = image
        numberLabel.isHidden = true
        monthLabel.isHidden = true
    }
    
    func configureMonthButton(with title: String) {
        let number = title.split(separator: " ")[0]
        numberLabel.text = String(number)
        titleLabel.isHidden = true
        imageView.isHidden = true
        monthLabel.isHidden = false
    }
        
    override var isSelected: Bool {
        didSet {
            if isSelected {
                button.backgroundColor = .systemBlue
                titleLabel.textColor = .white
                numberLabel.textColor = .white
                monthLabel.textColor = .white
                imageView.tintColor = .white
            } else {
                button.backgroundColor = .white
                titleLabel.textColor = .black
                numberLabel.textColor = .black
                monthLabel.textColor = .black
                imageView.tintColor = .black
            }
        }
    }
}
