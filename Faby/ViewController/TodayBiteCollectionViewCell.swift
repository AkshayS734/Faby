import UIKit

class TodayBiteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var todaysBiteLabel: UILabel!
    @IBOutlet weak var todaysBiteTimeLabel: UILabel!
    @IBOutlet weak var todaysBiteImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Rounded corners for cell
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = false
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOpacity = 0.1
//        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.backgroundColor = .systemGray6
        
        // Image styling
        todaysBiteImage.contentMode = .scaleToFill
        todaysBiteImage.layer.cornerRadius = 8
        todaysBiteImage.clipsToBounds = true
        
        // Label styling
        todaysBiteLabel.font = UIFont.boldSystemFont(ofSize: 16)
        todaysBiteLabel.textColor = .black
        
        todaysBiteTimeLabel.font = UIFont.systemFont(ofSize: 14)
        todaysBiteTimeLabel.textColor = .gray
    }
    
    func configure(with bite: TodayBite) {
        todaysBiteLabel.text = bite.title
        todaysBiteTimeLabel.text = bite.time
        todaysBiteImage.image = UIImage(named: bite.imageName)
    }
    
}
