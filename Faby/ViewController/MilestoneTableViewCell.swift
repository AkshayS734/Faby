import UIKit

class MilestoneTableViewCell: UITableViewCell {
    var dataController: DataController {
        return DataController.shared
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        detailTextLabel?.font = .systemFont(ofSize: 14)
        detailTextLabel?.textColor = .gray
        
        imageView?.contentMode = .scaleToFill
        imageView?.layer.cornerRadius = 8
        imageView?.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with milestone: GrowthMilestone, achievedDate: Date? = nil) {
        textLabel?.text = milestone.title
        
        if let date = achievedDate {
            detailTextLabel?.text = "Achieved on \(date.formatted(date: .abbreviated, time: .omitted))"
        }
        imageView?.image = dataController.loadMilestoneUserImage(for: milestone)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize: CGFloat = 50
        imageView?.frame = CGRect(x: 15, y: (contentView.frame.height - imageSize) / 2, width: imageSize, height: imageSize)
        textLabel?.frame.origin.x = imageView!.frame.maxX + 15
        detailTextLabel?.frame.origin.x = imageView!.frame.maxX + 15
        separatorInset = UIEdgeInsets(top: 0, left: imageView!.frame.maxX + 15, bottom: 0, right: 16)
    }
}
