import UIKit

class RepliesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var post: Post
    private let tableView = UITableView()
    private let replyTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    private let inputContainer = UIView()

    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
        self.title = post.title
        modalPresentationStyle = .pageSheet
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        setupReplyInput()
        setupKeyboardNotifications()
        
//        // Close button for modal dismissal
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeView))
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "replyCell")
        tableView.separatorStyle = .singleLine
        tableView.keyboardDismissMode = .interactive
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
        ])
    }
    
    private func setupReplyInput() {
        inputContainer.backgroundColor = .systemGray6
        inputContainer.layer.cornerRadius = 10
        inputContainer.layer.masksToBounds = true
        
        view.addSubview(inputContainer)
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            inputContainer.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        replyTextField.placeholder = "Write a reply..."
        replyTextField.borderStyle = .none
        replyTextField.backgroundColor = .white
        replyTextField.layer.cornerRadius = 8
        replyTextField.layer.masksToBounds = true
        replyTextField.font = UIFont.systemFont(ofSize: 16)
        replyTextField.returnKeyType = .send
        replyTextField.delegate = self
        
        inputContainer.addSubview(replyTextField)
        replyTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            replyTextField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 10),
            replyTextField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            replyTextField.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -60),
            replyTextField.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.addTarget(self, action: #selector(sendReply), for: .touchUpInside)
        
        inputContainer.addSubview(sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor)
        ])
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        UIView.animate(withDuration: 0.3) {
            self.inputContainer.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.height + self.view.safeAreaInsets.bottom)
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.inputContainer.transform = .identity
        }
    }
    
    @objc private func sendReply() {
        guard let text = replyTextField.text, !text.isEmpty else { return }
        
        // Get the current parent’s name
        guard let parentName = ParentDataModel.shared.currentParent?.name else {
            print("Error: No parent found")
            return
        }
        
        let newReply = Post(username: parentName, title: "", text: text)
        post.replies.append(newReply)
        tableView.reloadData()
        replyTextField.text = ""
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.replies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "replyCell", for: indexPath)
        let reply = post.replies[indexPath.row]
        cell.textLabel?.text = "\(reply.username): \(reply.text)"
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
//    @objc private func closeView() {
//        dismiss(animated: true, completion: nil)
//    }
}

extension RepliesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendReply()
        return true
    }
}
