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
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
            
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
        ])
//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.buttonTapped(_:)))
//        button.addGestureRecognizer(tap)
//        tap.cancelsTouchesInView = false
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func configure(with title: String) {
        button.setTitle(title, for: .normal)
    }
    
//    @objc func buttonTapped(_ sender: UITapGestureRecognizer) {
//        isSelected = !isSelected
//    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                button.backgroundColor = .systemBlue
                button.setTitleColor(.white, for: .normal)
            } else {
                button.backgroundColor = .white
                button.setTitleColor(.black, for: .normal)
            }
        }
    }
}
