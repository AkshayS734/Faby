import UIKit

class commentDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, PostViewDelegate {

    @IBOutlet var commentCollection: UICollectionView!
    
    // Properties to hold passed data
    var titleDetail: String?
    var passedTitle: String? = "Sample Title"
    var passedSubtitle: String? = "This is a sample subtitle."
    var selectedCategory: String?

    // Add a property for the comments data
    var comments: [Post] = []
    var expandedIndexPaths: Set<IndexPath> = [] // Track expanded state

    override func viewDidLoad() {
        super.viewDidLoad()
        if let category = selectedCategory {
               comments = PostDataManager.shared.getPosts(for: category) // ✅ Load updated posts
            commentCollection.reloadData()
           }
        // Set navigation title
        navigationItem.title = titleDetail ?? "Comments"
        
        // Set up collection view delegate and data source
        commentCollection.delegate = self
        commentCollection.dataSource = self
        
        // Register the XIB file for the cell
        commentCollection.register(UINib(nibName: "commentDetailsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "commentDetailsCollectionViewCell")
        
        // Set up the custom compositional layout
        commentCollection.collectionViewLayout = createCompositionalLayout()
        
        // Add navigation bar button for adding a comment
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Post", style: .plain, target: self, action: #selector(navigateToPostViewController))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPosts()
    }

    
    func reloadPosts() {
           if let category = selectedCategory {
               comments = PostDataManager.shared.getPosts(for: category)
               commentCollection.reloadData()
           }
       }
    @objc func navigateToPostViewController() {
        let storyboard = UIStoryboard(name: "ToddlerTalk", bundle: nil)
        if let postVC = storyboard.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController {
            postVC.selectedCategory = passedTitle // Pass the selected category
            postVC.delegate = self
            navigationController?.pushViewController(postVC, animated: true)
        }
    }
   

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "commentDetailsCollectionViewCell", for: indexPath) as? commentDetailsCollectionViewCell else {
            fatalError("Unable to dequeue commentDetailsCollectionViewCell")
        }
        
        let comment = comments[indexPath.row]
        cell.userImg.image = UIImage(systemName: "person.circle")
        cell.likecount.text = String(comment.likes)
        cell.username.text = comment.username
        cell.title.text = comment.title
        cell.subtitle.text = comment.text
        
        // Configure button actions
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(handleLikeButton(_:)), for: .touchUpInside)

        cell.commentButton.tag = indexPath.row
        cell.commentButton.addTarget(self, action: #selector(handleCommentButton(_:)), for: .touchUpInside)

        cell.shareButton.tag = indexPath.row
        cell.shareButton.addTarget(self, action: #selector(handleShareButton(_:)), for: .touchUpInside)
        // ✅ Double-tap to like the post
                let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
                doubleTap.numberOfTapsRequired = 2
                cell.addGestureRecognizer(doubleTap)

                // ✅ Expandable post card (Tap to View More)
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleExpand(_:)))
                cell.addGestureRecognizer(tapGesture)

                let isExpanded = expandedIndexPaths.contains(indexPath)
                cell.subtitle.numberOfLines = isExpanded ? 0 : 2
        
        return cell
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(260)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(260)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8)
        
        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Button Actions
    @objc func handleLikeButton(_ sender: UIButton) {
        let index = sender.tag
        comments[index].likes += 1
        commentCollection.reloadItems(at: [IndexPath(item: index, section: 0)])
    }

    @objc func handleCommentButton(_ sender: UIButton) {
            let index = sender.tag
            let comment = comments[index]
        let repliesVC = RepliesViewController(post: comment)
        let navController = UINavigationController(rootViewController: repliesVC)
            present(navController, animated: true)

        }



    @objc func handleShareButton(_ sender: UIButton) {
        let index = sender.tag
        let comment = comments[index]
        
        let textToShare = "\(comment.username) shared a comment: \(comment.text)"
        let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
            if let indexPath = commentCollection.indexPathForItem(at: sender.location(in: commentCollection)) {
                comments[indexPath.row].likes += 1
                commentCollection.reloadItems(at: [indexPath])
            }
        }
    // ✅ Expandable Post (Tap to View More)
        @objc func handleExpand(_ sender: UITapGestureRecognizer) {
            if let indexPath = commentCollection.indexPathForItem(at: sender.location(in: commentCollection)) {
                if expandedIndexPaths.contains(indexPath) {
                    expandedIndexPaths.remove(indexPath)
                } else {
                    expandedIndexPaths.insert(indexPath)
                }
                commentCollection.reloadItems(at: [indexPath])
            }
        }
    // MARK: - PostViewDelegate
    func didPostComment(_ comment: Post) {
        comments.insert(comment, at: 0) // Add new comment to the top of the list
        commentCollection.reloadData()  // Reload the collection view to reflect changes
    }
}
