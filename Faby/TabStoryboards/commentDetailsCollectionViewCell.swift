//
//  commentDetailsCollectionViewCell.swift
//  Toddler Talk1
//
//  Created by Vivek kumar on 26/01/25.
//

import UIKit

class commentDetailsCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var likecount: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttonStackView.layer.cornerRadius = 20
        stackView.layer.cornerRadius = 10
        stackView.layer.masksToBounds = true
        
        
        // Initialization code
//        @IBOutlet var username: UILabel!
//        @IBOutlet var userImg: UIImageView!
//        @IBOutlet var subtitle: UILabel!
//        @IBOutlet var title: UILabel!
//        @IBOutlet var commentButton: UIButton!
//
//        @IBOutlet var likeButton: UIButton!
//
//
//        @IBOutlet var shareButton: UIButton!
//
//
//        @IBOutlet var bookmarkButton: UIButton!
//
//
//
//        @IBOutlet var likecount: UILabel!
    }

}
