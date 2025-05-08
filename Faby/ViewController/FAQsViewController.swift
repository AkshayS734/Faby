import UIKit

class FAQsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    // FAQ data structure
    private struct FAQ {
        let question: String
        let answer: String
        var isExpanded: Bool = false
    }
    
    private var faqs: [FAQ] = [
        FAQ(question: "How do I add a new child profile?", 
            answer: "To add a new child profile, go to the Settings tab, tap on 'Parents Info' under PARENT PROFILE section, and then tap the '+' button to add a new child."),
        FAQ(question: "How do I track my child's vaccinations?", 
            answer: "You can track vaccinations by going to the VACCITIME section in Settings. Tap on 'Vaccine History' to see past vaccinations or 'Administered Vaccines' to add new ones."),
        FAQ(question: "How do I track my child's growth milestones?", 
            answer: "Navigate to the GROWTRACK section in Settings and tap on 'Milestone track' to view and update your child's developmental milestones."),
        FAQ(question: "How do I set up meal plans?", 
            answer: "Go to the TODBITE section in Settings and tap on 'Your plan' to set up or modify your child's meal plans."),
        FAQ(question: "How do I update my child's measurements?", 
            answer: "You can update your child's height, weight, and other measurements by tapping on their profile card at the top of the Settings screen."),
        FAQ(question: "Can I share my child's profile with family members?", 
            answer: "Currently, profile sharing is not available but we're working on adding this feature in a future update."),
        FAQ(question: "How do I reset my password?", 
            answer: "To reset your password, log out of the app, tap on 'Forgot Password' on the login screen, and follow the instructions sent to your registered email."),
        FAQ(question: "Is my data secure?", 
            answer: "Yes, we take data security very seriously. All your data is encrypted and stored securely according to industry standards. We never share your personal information with third parties without your consent.")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Frequently Asked Questions"
        view.backgroundColor = .systemBackground
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FAQTableViewCell.self, forCellReuseIdentifier: "FAQCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return faqs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FAQCell", for: indexPath) as! FAQTableViewCell
        let faq = faqs[indexPath.row]
        cell.configure(with: faq.question, answer: faq.answer, isExpanded: faq.isExpanded)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Toggle expansion state
        faqs[indexPath.row].isExpanded.toggle()
        
        // Animate the cell update
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Common Questions"
    }
}

// MARK: - FAQ Table View Cell
class FAQTableViewCell: UITableViewCell {
    
    private let questionLabel = UILabel()
    private let answerLabel = UILabel()
    private let expandIndicator = UIImageView()
    private let containerView = UIView()
    
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
        
        // Container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 10
        contentView.addSubview(containerView)
        
        // Question label
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        questionLabel.numberOfLines = 0
        containerView.addSubview(questionLabel)
        
        // Expand indicator
        expandIndicator.translatesAutoresizingMaskIntoConstraints = false
        expandIndicator.contentMode = .scaleAspectFit
        expandIndicator.tintColor = .systemBlue
        expandIndicator.image = UIImage(systemName: "chevron.down")
        containerView.addSubview(expandIndicator)
        
        // Answer label
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.font = UIFont.systemFont(ofSize: 14)
        answerLabel.textColor = .darkGray
        answerLabel.numberOfLines = 0
        answerLabel.isHidden = true
        containerView.addSubview(answerLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            questionLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            questionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: expandIndicator.leadingAnchor, constant: -8),
            
            expandIndicator.centerYAnchor.constraint(equalTo: questionLabel.centerYAnchor),
            expandIndicator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            expandIndicator.widthAnchor.constraint(equalToConstant: 20),
            expandIndicator.heightAnchor.constraint(equalToConstant: 20),
            
            answerLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 12),
            answerLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            answerLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            answerLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with question: String, answer: String, isExpanded: Bool) {
        questionLabel.text = question
        answerLabel.text = answer
        answerLabel.isHidden = !isExpanded
        
        // Update the expand indicator
        let imageName = isExpanded ? "chevron.up" : "chevron.down"
        expandIndicator.image = UIImage(systemName: imageName)
        
        // Update constraints for collapsed state
        if !isExpanded {
            containerView.bottomAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 16).isActive = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset any custom configurations
        answerLabel.isHidden = true
        expandIndicator.image = UIImage(systemName: "chevron.down")
    }
}
