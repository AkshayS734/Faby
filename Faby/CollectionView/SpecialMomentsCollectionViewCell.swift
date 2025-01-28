import UIKit

class SpecialMomentsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var specialMomentTitle: UILabel!
    @IBOutlet weak var specialMomentCategory: UILabel!
    @IBOutlet weak var specialMomentDate: UILabel!
    @IBOutlet weak var specialMomentsImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    private func setupUI() {
        specialMomentsImage.layer.cornerRadius = 10
        specialMomentsImage.clipsToBounds = true
        specialMomentsImage.contentMode = .scaleAspectFill
        
        specialMomentTitle.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        specialMomentTitle.textColor = .darkText
        
        specialMomentCategory.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        specialMomentCategory.textColor = .gray
        
        specialMomentDate.font = UIFont.systemFont(ofSize: 12, weight: .light)
        specialMomentDate.textColor = .lightGray
    }
    
    func configure(with milestone: (GrowthMilestone, Date)) {
        let (milestoneDetail, achievedDate) = milestone
        specialMomentTitle.text = milestoneDetail.title
        specialMomentCategory.text = milestoneDetail.category.rawValue.capitalized
        specialMomentDate.text = achievedDate.formatted()
        if let userImage = milestoneDetail.userImagePath.flatMap({ UIImage(contentsOfFile: $0) }) {
            specialMomentsImage.image = userImage
        } else {
            specialMomentsImage.image = UIImage(named: milestoneDetail.image)
        }
    }

}
