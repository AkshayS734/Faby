//
//  PostViewController.swift
//  Toddler Talk1
//
//  Created by Vivek Kumar on 26/01/25.
//

import UIKit

// Define the delegate protocol
protocol PostViewDelegate: AnyObject {
    func didPostComment(_ comment: Post)
}

class PostViewController: UIViewController, UITextViewDelegate {

    // Outlets
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var titleTextBox: UITextField!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var userImage: UIImageView!

    let placeholderLabel = UILabel()

    weak var delegate: PostViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.text = "VIVEK CHAUDHARY"
        stackView.layer.cornerRadius = 12
        configurePlaceholder()
        commentTextView.delegate = self
    }
  
    @IBAction func postComment(_ sender: Any) {
       
        guard let title = titleTextBox.text, let text = commentTextView.text, !title.isEmpty, !text.isEmpty else {
            showAlert(message: "Please enter both a title and a comment.")
            return
        }
        PostDataManager.shared.addPost(username: "CurrentUser", title: title, text: text)

            print("✅ Post added successfully, navigating back!")

//            self.navigationController?.popViewController(animated: true)
        let newComment = Post(username: "VIVEK CHAUDHARY", title: title, text: text, likes: 0, replies: [])
        
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
