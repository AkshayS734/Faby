//import UIKit
//
//class NewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,PostViewDelegate {
//    var titleDetail : String?
//    func didPostComment(_ comment: Comment) {
//        print("Comment received: \(comment)")
//        comments.append(comment)
//        NewCollectionView.reloadData()
//    }
//    @IBOutlet var NewCollectionView: UICollectionView! // Connect this to your storyboard
//
//    // Properties to hold passed data
//    var passedTitle: String? = "Sample Title"
//    var passedSubtitle: String? = "This is a sample subtitle."
//
//    // Add a property for the comments data
//    var comments: [Comment] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        print("Passed Title: \(passedTitle ?? "No title")")
//        print("Passed Subtitle: \(passedSubtitle ?? "No subtitle")")
//        print("Comments: \(comments)")
//        navigationItem.title = titleDetail
//        // Set up collection view delegate and data source
//        NewCollectionView.delegate = self
//        NewCollectionView.dataSource = self
//
//        // Register the XIB file for the cell
//        NewCollectionView.register(UINib(nibName: "NewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewCollectionViewCell")
//
//        // Set up the custom compositional layout
//        NewCollectionView.collectionViewLayout = createCompositionalLayout()
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return comments.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewCollectionViewCell", for: indexPath) as? NewCollectionViewCell else {
//            fatalError("Unable to dequeue NewCollectionViewCell")
//        }
//
//        let comment = comments[indexPath.row]
//        cell.userImg.image = UIImage(systemName: "person.circle")
//        cell.likecount.text = String(comment.likes)
//        cell.username.text = comment.username
//        cell.title.text = comment.title
//        cell.subtitle.text = comment.text
//
//        return cell
//    }
//
//    func createCompositionalLayout() -> UICollectionViewLayout {
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .absolute(200)
//        )
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .absolute(200)
//        )
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        let section = NSCollectionLayoutSection(group: group)
//        section.interGroupSpacing = 8
//        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
//
//        return UICollectionViewCompositionalLayout(section: section)
//    }
//
//    @IBAction func navigateToPostViewController(_ sender: UIBarButtonItem) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let postVC = storyboard.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController {
//            postVC.delegate = self
//            navigationController?.pushViewController(postVC, animated: true)
//        }
//    }
//
//
//}
//
import UIKit

class NewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, PostViewDelegate {
    @IBOutlet var newCollectionView: UICollectionView! // Connect this to your storyboard
    
    // Properties to hold passed data
    var titleDetail: String?
    var passedTitle: String? = "Sample Title"
    var passedSubtitle: String? = "This is a sample subtitle."
    
    // Add a property for the comments data
    var comments: [Comment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set navigation title
        navigationItem.title = titleDetail
        
        // Set up collection view delegate and data source
        newCollectionView.delegate = self
        newCollectionView.dataSource = self
        
        // Register the XIB file for the cell
        newCollectionView.register(UINib(nibName: "NewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewCollectionViewCell")
        
        // Set up the custom compositional layout
        newCollectionView.collectionViewLayout = createCompositionalLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewCollectionViewCell", for: indexPath) as? NewCollectionViewCell else {
            fatalError("Unable to dequeue NewCollectionViewCell")
        }
        
        let comment = comments[indexPath.row]
        cell.userImg.image = UIImage(systemName: "person.circle")
        cell.likecount.text = String(comment.likes)
        cell.username.text = comment.username
        cell.title.text = comment.title
        cell.subtitle.text = comment.text
        
        return cell
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    @IBAction func navigateToPostViewController(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let postVC = storyboard.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController {
            postVC.delegate = self
            navigationController?.pushViewController(postVC, animated: true)
        }
    }
    
    // Conform to PostViewDelegate
    func didPostComment(_ comment: Comment) {
        comments.insert(comment, at: 0) // Add new comment to the top of the list
        newCollectionView.reloadData()  // Reload the collection view to reflect changes
    }
}
