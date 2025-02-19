//
//  PostViewController.swift
//  Toddler Talk1
//
//  Created by Vivek Kumar on 26/01/25.
//

import UIKit

// Define the delegate protocol
protocol PostViewDelegate: AnyObject {
    func didPostComment(_ comment: Comment)
}

class PostViewController: UIViewController, UITextViewDelegate {

    // Outlets
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var titleTextBox: UITextField!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var userImage: UIImageView!
    
    // Placeholder label for the UITextView
    let placeholderLabel = UILabel()
    
    // Delegate property
    weak var delegate: PostViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dynamically set the username label from ParentDataModel
        if let currentParent = ParentDataModel.shared.currentParent {
            userName.text = currentParent.name
        } else {
            userName.text = "Unknown User" // Fallback text
        }
        
        stackView.layer.cornerRadius = 12
        
        // Configure placeholder for UITextView
        configurePlaceholder()
        
        // Set the UITextView delegate
        commentTextView.delegate = self
    }
    
    // Action for posting a comment
    @IBAction func postComment(_ sender: Any) {
        // Ensure valid input
        guard let title = titleTextBox.text, let text = commentTextView.text, !title.isEmpty, !text.isEmpty else {
            showAlert(message: "Please enter both a title and a comment.")
            return
        }

        guard let currentParent = ParentDataModel.shared.currentParent else {
            showAlert(message: "Error: No parent found!")
            return
        }

        // ✅ Call `addPost` without passing `username`
        PostDataManager.shared.addPost(title: title, text: text)

        print("✅ Post added successfully, navigating back!")

        // ✅ Create a new `Post` instance with `parentId`
        let newComment = Post(
       
            username: currentParent.name,
            title: title,
            text: text,
            likes: 0,
            replies: []
        )

        // Call the delegate method
        delegate?.didPostComment(newComment)
        
        // Navigate back to the previous screen
        navigationController?.popViewController(animated: true)
    }
    
    // Helper function to show an alert
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    // Configure the placeholder label for UITextView
    private func configurePlaceholder() {
        placeholderLabel.text = "Enter your comment here..."
        placeholderLabel.font = UIFont.systemFont(ofSize: 16)
        placeholderLabel.textColor = .lightGray
        placeholderLabel.frame = CGRect(x: 5, y: 8, width: commentTextView.frame.width - 10, height: 20)
        commentTextView.addSubview(placeholderLabel)
        
        // Initially show or hide the placeholder based on the text
        placeholderLabel.isHidden = !commentTextView.text.isEmpty
    }
    
    // UITextViewDelegate method to manage placeholder visibility
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
