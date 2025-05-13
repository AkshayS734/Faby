//
//  PostCardCellDelegate.swift
//  Faby
//
//  Created by Vivek kumar on 02/05/25.
//

import UIKit

protocol PostCardCellDelegate: AnyObject {
    func didTapComment(for post: Post)
    func didTapMore(for post: Post)
    func didTapSave(for post: Post)
    func didTapReport(for post: Post)
    
    // Optional method to handle share functionality directly
    func sharePost(_ post: Post, from viewController: UIViewController)
    
    // Method to handle navigation to post details
    func didTapPostForDetails(_ post: Post)
}
