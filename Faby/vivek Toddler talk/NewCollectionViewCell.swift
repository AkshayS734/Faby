//
//  NewCollectionViewCell.swift
//  talk
//
//  Created by Batch - 1 on 20/01/25.
//

import UIKit

class NewCollectionViewCell: UICollectionViewCell {

    @IBOutlet var commentButton: UIButton!
    
    @IBOutlet var likeButton: UIButton!
    
    
    @IBOutlet var shareButton: UIButton!
    
    
    @IBOutlet var bookmarkButton: UIButton!
    
    
    
    @IBOutlet var likecount: UILabel!
    
   
    
    
    @IBOutlet var username: UILabel!
    @IBOutlet var userImg: UIImageView!
    @IBOutlet var subtitle: UILabel!
    @IBOutlet var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
