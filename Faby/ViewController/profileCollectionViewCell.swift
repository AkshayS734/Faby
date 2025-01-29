//
//  profileCollectionViewCell.swift
//  profilepage
//
//  Created by Vivek kumar on 26/01/25.
//

import UIKit

class profileCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dateOfBirth: UILabel!
 
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var height: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var secondStack: UIStackView!
    @IBOutlet weak var firstStack: UIStackView!
    @IBOutlet weak var imageNameStack: UIStackView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageNameStack.layer.cornerRadius = 10
        firstStack.layer.cornerRadius = 10
        secondStack.layer.cornerRadius = 10
        userImg.layer.cornerRadius = userImg.frame.height / 2
        userImg.clipsToBounds = true
               self.layer.cornerRadius = 10
               self.layer.borderColor = UIColor.lightGray.cgColor
               self.layer.borderWidth = 0.5
               self.clipsToBounds = true
    }

}
