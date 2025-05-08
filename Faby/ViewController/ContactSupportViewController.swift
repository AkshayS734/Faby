import UIKit
import MessageUI

class ContactSupportViewController: UIViewController, MFMailComposeViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let headerLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    // Support category selection
    private let categoryLabel = UILabel()
    private var categoryCollectionView: UICollectionView!
    private let categoryHeight: CGFloat = 120
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCollectionView()
    }
    
    // Contact methods
    private let contactMethodsLabel = UILabel()
    private let emailButton = UIButton(type: .system)
    private let chatButton = UIButton(type: .system)
    
    // Support categories
    private struct SupportCategory {
        let title: String
        let icon: String // SF Symbol name
        let color: UIColor
    }
    
    // Colors from the shared image with adjusted opacity for better text visibility
    private let emailBlueColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.8) // Light blue from image
    private let liveChatGreenColor = UIColor(red: 0.2, green: 0.9, blue: 0.6, alpha: 0.8) // Light green from image
    
    private let supportCategories: [SupportCategory] = [
        SupportCategory(title: "Technical", icon: "gear", color: UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.6)),
        SupportCategory(title: "Account", icon: "person.circle", color: UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.6)),
        SupportCategory(title: "Billing", icon: "creditcard", color: UIColor(red: 0.2, green: 0.9, blue: 0.6, alpha: 0.6)),
        SupportCategory(title: "Features", icon: "star", color: UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.6)),
        SupportCategory(title: "Bug Report", icon: "questionmark.circle", color: UIColor(red: 0.2, green: 0.9, blue: 0.6, alpha: 0.6))
    ]
    
    private var selectedCategoryIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contact Support"
        view.backgroundColor = .systemBackground
        setupScrollView()
        setupUI()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        categoryCollectionView.backgroundColor = .clear
        categoryCollectionView.showsHorizontalScrollIndicator = false
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: "CategoryCell")
        categoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupUI() {
        // Header Label
        headerLabel.text = "How can we help you?"
        headerLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        headerLabel.textAlignment = .center
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerLabel)
        
        // Description Label
        descriptionLabel.text = "We're here to assist you with any questions or issues you might have"
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        // Category Label
        categoryLabel.text = "What do you need help with?"
        categoryLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(categoryLabel)
        
        // Category Collection View
        contentView.addSubview(categoryCollectionView)
        
        // Contact Methods Label
        contactMethodsLabel.text = "Choose how you'd like to reach us"
        contactMethodsLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        contactMethodsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contactMethodsLabel)
        
        // Email Button
        emailButton.setTitle("Email Support", for: .normal)
        emailButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        emailButton.backgroundColor = emailBlueColor
        emailButton.setTitleColor(.white, for: .normal) // White text for better contrast
        emailButton.layer.cornerRadius = 25 // Rounded corners to match image
        emailButton.addTarget(self, action: #selector(emailButtonTapped), for: .touchUpInside)
        emailButton.translatesAutoresizingMaskIntoConstraints = false
        emailButton.setImage(UIImage(systemName: "envelope.fill"), for: .normal)
        emailButton.tintColor = .white // White icon for better visibility
        emailButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        emailButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        // Add a subtle shadow for better visibility
        emailButton.layer.shadowColor = UIColor.black.cgColor
        emailButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        emailButton.layer.shadowRadius = 2
        emailButton.layer.shadowOpacity = 0.1
        contentView.addSubview(emailButton)
        
        // Chat Button
        chatButton.setTitle("Live Chat", for: .normal)
        chatButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        chatButton.backgroundColor = liveChatGreenColor
        chatButton.setTitleColor(.white, for: .normal) // White text for better contrast
        chatButton.layer.cornerRadius = 25 // Rounded corners to match image
        chatButton.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
        chatButton.translatesAutoresizingMaskIntoConstraints = false
        chatButton.setImage(UIImage(systemName: "bubble.left.fill"), for: .normal) // Chat bubble icon to match image
        chatButton.tintColor = .white // White icon for better visibility
        chatButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        chatButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        // Add a subtle shadow for better visibility
        chatButton.layer.shadowColor = UIColor.black.cgColor
        chatButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        chatButton.layer.shadowRadius = 2
        chatButton.layer.shadowOpacity = 0.1
        contentView.addSubview(chatButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            categoryLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            categoryCollectionView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 16),
            categoryCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categoryCollectionView.heightAnchor.constraint(equalToConstant: categoryHeight),
            
            contactMethodsLabel.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 30),
            contactMethodsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contactMethodsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            emailButton.topAnchor.constraint(equalTo: contactMethodsLabel.bottomAnchor, constant: 16),
            emailButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailButton.heightAnchor.constraint(equalToConstant: 55),
            
            chatButton.topAnchor.constraint(equalTo: emailButton.bottomAnchor, constant: 16),
            chatButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            chatButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            chatButton.heightAnchor.constraint(equalToConstant: 55),
            chatButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    // MARK: - Button Actions
    
    @objc private func emailButtonTapped() {
        let category = supportCategories[selectedCategoryIndex]
        
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            // Set appropriate email based on category
            let emailAddress = getEmailForCategory(category.title)
            mailComposer.setToRecipients([emailAddress])
            
            // Create a more specific subject line
            let subject = "Faby App - \(category.title) Request"
            mailComposer.setSubject(subject)
            
            // Create a more helpful email template
            let messageBody = """
            Hello Faby Support Team,
            
            I need help with: \(category.title)
            
            Please describe your issue here:
            
            
            Device Information:
            iOS Version: \(UIDevice.current.systemVersion)
            Device Model: \(UIDevice.current.model)
            App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
            
            Thank you!
            """
            
            mailComposer.setMessageBody(messageBody, isHTML: false)
            
            present(mailComposer, animated: true)
        } else {
            // Fallback if mail isn't available
            let emailAddress = getEmailForCategory(category.title)
            let alertController = UIAlertController(
                title: "Email Not Available",
                message: "Please email us directly at \(emailAddress)",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "Copy Email", style: .default) { _ in
                UIPasteboard.general.string = emailAddress
                self.showToast(message: "Email address copied to clipboard")
            })
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alertController, animated: true)
        }
    }
    
    private func getEmailForCategory(_ category: String) -> String {
        // Return different email addresses based on support category
        switch category {
        case "Technical Support":
            return "tech@faby.com"
        case "Account Help":
            return "accounts@faby.com"
        case "Billing Questions":
            return "billing@faby.com"
        case "Bug Reports":
            return "bugs@faby.com"
        default:
            return "support@faby.com"
        }
    }
    

    
    @objc private func chatButtonTapped() {
        let category = supportCategories[selectedCategoryIndex]
        
        // In a real app, this would connect to a chat service
        // For now, we'll simulate starting a chat session
        let chatVC = ChatSupportViewController()
        chatVC.supportCategory = category.title
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    private func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0
        
        view.addSubview(toastLabel)
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            toastLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            toastLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            toastLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastLabel.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        })
    }
    
    // MARK: - UICollectionViewDelegate & UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return supportCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCollectionViewCell
        let category = supportCategories[indexPath.item]
        cell.configure(with: category.title, iconName: category.icon, color: category.color, isSelected: indexPath.item == selectedCategoryIndex)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategoryIndex = indexPath.item
        collectionView.reloadData()
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Animate the selection
        if let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell {
            UIView.animate(withDuration: 0.2, animations: {
                cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    cell.transform = .identity
                }
            }
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 100)
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        
        if result == .sent {
            showToast(message: "Thank you! Your email has been sent.")
        }
    }
}
