//
//  cardDetailsCollectionViewCell.swift
//  Toddler Talk1
//
//  Created by Vivek kumar on 25/01/25.
//

import UIKit

class cardDetailsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        stackView.layer.cornerRadius = 10
                stackView.layer.masksToBounds = true
    }

}
