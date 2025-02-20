import UIKit

class UserPostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PostViewDelegate {

    var commentDataManager: PostDataManager = PostDataManager.shared
    @IBOutlet weak var tableView: UITableView!
    var posts: [Post] = []

    // Placeholder Label
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "History is empty right now."
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 16)
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupPlaceholder()
        fetchPosts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPosts()
    }

    func setupPlaceholder() {
        tableView.backgroundView = placeholderLabel
    }

    func fetchPosts() {
        posts = commentDataManager.getUserPosts()
        
        // Show the placeholder if no posts, otherwise hide it
        if posts.isEmpty {
            placeholderLabel.isHidden = false
        } else {
            placeholderLabel.isHidden = true
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "PostCell")
        
        let post = posts[indexPath.row]
        cell.textLabel?.text = post.title
        cell.detailTextLabel?.text = "\(post.username): \(post.text)"
        return cell
    }

    // MARK: - Delegate Method (Updating UI When a New Post is Added)
    func didPostComment(_ comment: Post) {
        posts.insert(comment, at: 0)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - Prepare for Post Creation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let postVC = segue.destination as? PostViewController {
            postVC.delegate = self
        }
    }
}
