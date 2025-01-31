//
//  PostListViewController.swift
//  Talk
//

import UIKit

class UserPostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PostViewDelegate {
    var commentDataManager: PostDataManager = PostDataManager.shared
    @IBOutlet weak var tableView: UITableView!
    var posts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchPosts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPosts()
    }

    func fetchPosts() {
        posts = commentDataManager.getUserPosts()
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
            postVC.delegate = self  // Setting delegate
        }
    }
}
