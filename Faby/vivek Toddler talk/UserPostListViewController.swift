import UIKit

class UserPostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PostViewDelegate {

    var commentDataManager: PostDataManager = PostDataManager.shared
    @IBOutlet weak var tableView: UITableView!
    var postsByCategory: [String: [Post]] = [:]
    var categoryList: [String] = []

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
        postsByCategory = commentDataManager.getPostsByCategory()
        categoryList = Array(postsByCategory.keys).sorted()
        
        let allPosts = postsByCategory.flatMap { $0.value }
        placeholderLabel.isHidden = !allPosts.isEmpty
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - TableView Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return categoryList.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categoryList[section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = categoryList[section]
        return postsByCategory[category]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "PostCell")
        
        let category = categoryList[indexPath.section]
        if let post = postsByCategory[category]?[indexPath.row] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, h:mm a"
            let formattedDate = dateFormatter.string(from: post.timeStamp)

            cell.textLabel?.text = post.title
            cell.detailTextLabel?.text = "\(post.username): \(post.text) \nPosted on \(formattedDate)"
            cell.detailTextLabel?.numberOfLines = 0
        }
        
        return cell
    }

    // MARK: - Delegate Method
    func didPostComment(_ comment: Post) {
        fetchPosts()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let postVC = segue.destination as? PostViewController {
            postVC.delegate = self
        }
    }
}
