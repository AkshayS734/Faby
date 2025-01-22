//import UIKit
//
//// Define the delegate protocol
//protocol PostViewDelegate: AnyObject {
//    func didPostComment(_ comment: Comment)
//}
//
//class PostViewController: UIViewController {
//
//    @IBOutlet var CreateCollection: UICollectionView! // Connect this to your storyboard
//    weak var delegate: PostViewDelegate? // Delegate property
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Register the XIB file
//        CreateCollection.register(UINib(nibName: "createPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "createPostCollectionViewCell")
//
//        // Set the delegate and data source
//        CreateCollection.delegate = self
//        CreateCollection.dataSource = self
//    }
//
//    @IBAction func postButtonTappedAction(_ sender: UIBarButtonItem) {
//        // Ensure the cell is valid
//        guard let cell = CreateCollection.cellForItem(at: IndexPath(item: 0, section: 0)) as? createPostCollectionViewCell else {
//            print("Cell not found!")
//            return
//        }
//
//        // Ensure the comment box is not empty
//        guard let commentText = cell.commentBox.text, !commentText.isEmpty else {
//            let alert = UIAlertController(title: "Error", message: "Comment cannot be empty!", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
//            present(alert, animated: true, completion: nil)
//            return
//        }
//
//        // Create a new Comment object
//        let newComment = Comment(
//            username: cell.userName.text ?? "vivek kumar",
//            title: "Sample Title", // You can replace with actual dynamic title if necessary
//            text: commentText,
//            likes: 0,
//            replies: []
//        )
//
//        // Notify the delegate to handle the new comment
//        delegate?.didPostComment(newComment)
//
//        // Go back to the previous view
//        navigationController?.popViewController(animated: true)
//    }
//}
//
//extension PostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 1 // One input form per `PostViewController`
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(
//            withReuseIdentifier: "createPostCollectionViewCell",
//            for: indexPath
//        ) as? createPostCollectionViewCell else {
//            fatalError("Unable to dequeue createPostCollectionViewCell")
//        }
//
//        // Configure the cell (optional if needed)
//        cell.userName.text = "Vivek kumar" // Replace with dynamic data if available
//        cell.userImage.image = UIImage(systemName: "person.circle") // Example placeholder
//
//        return cell
//    }
//}
import UIKit

// Define the delegate protocol
protocol PostViewDelegate: AnyObject {
    func didPostComment(_ comment: Comment)
}

class PostViewController: UIViewController {
    
    @IBOutlet var createCollection: UICollectionView! // Connect this to your storyboard
    weak var delegate: PostViewDelegate? // Delegate property
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the XIB file
        createCollection.register(UINib(nibName: "createPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "createPostCollectionViewCell")
        
        // Set the delegate and data source
        createCollection.delegate = self
        createCollection.dataSource = self
    }
    
    @IBAction func postButtonTappedAction(_ sender: UIBarButtonItem) {
        // Ensure the cell is valid
        guard let cell = createCollection.cellForItem(at: IndexPath(item: 0, section: 0)) as? createPostCollectionViewCell else {
            print("Cell not found!")
            return
        }
        
        // Ensure the comment box is not empty
        guard let commentText = cell.commentBox.text, !commentText.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Comment cannot be empty!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        // Create a new Comment object
        let newComment = Comment(
            username: cell.userName.text ?? "vivek kumar",
            title: "Sample Title", // Can be replaced with dynamic data
            text: commentText,
            likes: 0,
            replies: []
        )
        
        // Notify the delegate
        delegate?.didPostComment(newComment)
        
        // Navigate back to the previous view
        navigationController?.popViewController(animated: true)
    }
}

extension PostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 // One input form per `PostViewController`
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "createPostCollectionViewCell",
            for: indexPath
        ) as? createPostCollectionViewCell else {
            fatalError("Unable to dequeue CreatePostCollectionViewCell")
        }
        
        // Configure the cell
        cell.userName.text = "VIVEK CHAUDHARY" // Replace with dynamic user name if available
        cell.userImage.image = UIImage(systemName: "person.circle") // Example placeholder
        
        return cell
    }
}
