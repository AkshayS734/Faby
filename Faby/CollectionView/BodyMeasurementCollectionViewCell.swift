import UIKit

class BodyMeasurementCollectionViewCell: UICollectionViewCell {

    static let identifier = "BodyMeasurementCollectionViewCell"
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var labelImage: UIImageView!
    @IBOutlet weak var chevronButton: UIButton!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var measurementUnitLabel: UILabel!
    @IBOutlet weak var measurementNumberLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }

}
