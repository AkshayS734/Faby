import UIKit

class ChatSupportViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var supportCategory: String = ""
    var supportDescription: String = ""
    
    private let tableView = UITableView()
    private let messageInputView = UIView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    
    private struct ChatMessage {
        let text: String
        let isFromUser: Bool
        let timestamp: Date
    }
    
    private var messages: [ChatMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Live Chat Support"
        view.backgroundColor = .systemBackground
        setupUI()
        startChat()
    }
    
    private func setupUI() {
        // Table View
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "MessageCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.keyboardDismissMode = .interactive
        view.addSubview(tableView)
        
        // Message Input View
        messageInputView.backgroundColor = .systemGray6
        messageInputView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageInputView)
        
        // Message Text Field
        messageTextField.placeholder = "Type your message..."
        messageTextField.borderStyle = .roundedRect
        messageTextField.delegate = self
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        messageInputView.addSubview(messageTextField)
        
        // Send Button
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.systemBlue, for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        messageInputView.addSubview(sendButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor),
            
            messageInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            messageInputView.heightAnchor.constraint(equalToConstant: 60),
            
            messageTextField.leadingAnchor.constraint(equalTo: messageInputView.leadingAnchor, constant: 15),
            messageTextField.centerYAnchor.constraint(equalTo: messageInputView.centerYAnchor),
            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            
            sendButton.trailingAnchor.constraint(equalTo: messageInputView.trailingAnchor, constant: -15),
            sendButton.centerYAnchor.constraint(equalTo: messageInputView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60)
        ])
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func startChat() {
        // Add welcome messages
        let welcomeMessage = ChatMessage(
            text: "Welcome to Faby Support! How can we help you with \(supportCategory.lowercased()) today?",
            isFromUser: false,
            timestamp: Date()
        )
        
        let categoryMessage = ChatMessage(
            text: "You selected: \(supportCategory)\n\(supportDescription)",
            isFromUser: false,
            timestamp: Date().addingTimeInterval(1)
        )
        
        let agentMessage = ChatMessage(
            text: "My name is Sarah, and I'll be your support specialist today. Please describe your issue, and I'll do my best to help you.",
            isFromUser: false,
            timestamp: Date().addingTimeInterval(2)
        )
        
        messages.append(welcomeMessage)
        messages.append(categoryMessage)
        messages.append(agentMessage)
        
        tableView.reloadData()
        scrollToBottom()
    }
    
    @objc private func sendButtonTapped() {
        guard let text = messageTextField.text, !text.isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(text: text, isFromUser: true, timestamp: Date())
        messages.append(userMessage)
        
        // Clear text field
        messageTextField.text = ""
        
        // Update table view
        tableView.reloadData()
        scrollToBottom()
        
        // Simulate agent response after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.simulateAgentResponse(to: text)
        }
    }
    
    private func simulateAgentResponse(to userMessage: String) {
        // Generate a contextual response based on user message
        let response: String
        
        if userMessage.lowercased().contains("thank") {
            response = "You're welcome! Is there anything else I can help you with today?"
        } else if userMessage.lowercased().contains("wait time") || userMessage.lowercased().contains("how long") {
            response = "We're typically able to resolve \(supportCategory.lowercased()) issues within 24-48 hours. We'll prioritize your case and get back to you as soon as possible."
        } else if userMessage.lowercased().contains("manager") || userMessage.lowercased().contains("supervisor") {
            response = "I'd be happy to escalate this to my supervisor. They'll review your case and reach out to you directly within 1 business day."
        } else {
            // Default responses
            let defaultResponses = [
                "I understand your concern. Let me look into this for you.",
                "Thank you for providing that information. Let me check what we can do to help.",
                "I'm sorry you're experiencing this issue. We'll work to resolve it as quickly as possible.",
                "I've made a note of your issue. Is there anything else you'd like to add?",
                "Let me check with our \(supportCategory.lowercased()) team for more information about this."
            ]
            response = defaultResponses.randomElement() ?? "Thank you for your message. We'll look into this right away."
        }
        
        // Add agent message
        let agentMessage = ChatMessage(text: response, isFromUser: false, timestamp: Date())
        messages.append(agentMessage)
        
        // Update table view
        tableView.reloadData()
        scrollToBottom()
    }
    
    private func scrollToBottom() {
        if messages.count > 0 {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    // MARK: - Keyboard Handling
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: 0.3) {
            self.messageInputView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight + self.view.safeAreaInsets.bottom)
            self.tableView.contentInset.bottom = keyboardHeight
            self.tableView.scrollIndicatorInsets.bottom = keyboardHeight
            self.scrollToBottom()
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.messageInputView.transform = .identity
            self.tableView.contentInset.bottom = 0
            self.tableView.scrollIndicatorInsets.bottom = 0
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.row]
        cell.configure(with: message.text, isFromUser: message.isFromUser)
        return cell
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonTapped()
        return true
    }
}

// MARK: - Chat Message Cell

class ChatMessageCell: UITableViewCell {
    
    private let messageLabel = UILabel()
    private let bubbleView = UIView()
    private let padding: CGFloat = 12
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // Bubble View
        bubbleView.layer.cornerRadius = 16
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleView)
        
        // Message Label
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: padding),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: padding),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -padding),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -padding),
            
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75)
        ])
    }
    
    func configure(with message: String, isFromUser: Bool) {
        messageLabel.text = message
        
        if isFromUser {
            bubbleView.backgroundColor = .systemBlue
            messageLabel.textColor = .white
            
            // User messages aligned to the right
            bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 60).isActive = true
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        } else {
            bubbleView.backgroundColor = .systemGray5
            messageLabel.textColor = .label
            
            // Agent messages aligned to the left
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -60).isActive = true
        }
    }
}
