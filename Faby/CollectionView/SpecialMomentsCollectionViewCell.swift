import UIKit

class SpecialMomentsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var specialMomentTitle: UILabel!
    @IBOutlet weak var specialMomentCategory: UILabel!
    @IBOutlet weak var specialMomentDate: UILabel!
    @IBOutlet weak var specialMomentsImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupImageConstraints()
    }
    private func setupUI() {
        specialMomentsImage.layer.cornerRadius = 10
        specialMomentsImage.clipsToBounds = true
        specialMomentsImage.contentMode = .scaleToFill
        
        specialMomentTitle.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        specialMomentTitle.textColor = .darkText
        
        specialMomentCategory.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        specialMomentCategory.textColor = .gray
        
        specialMomentDate.font = UIFont.systemFont(ofSize: 12, weight: .light)
        specialMomentDate.textColor = .lightGray
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
        
        specialMomentTitle.text = milestoneDetail.title
        specialMomentCategory.text = milestoneDetail.category.rawValue.capitalized
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        specialMomentDate.text = dateFormatter.string(from: achievedDate)
        if let userImagePath = milestoneDetail.userImagePath,
           let userImage = UIImage(contentsOfFile: userImagePath) {
            specialMomentsImage.image = userImage
        } else {
            specialMomentsImage.image = UIImage(named: milestoneDetail.image)
        }
    }
    
}
