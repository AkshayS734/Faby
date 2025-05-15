import UIKit
import AVKit

protocol MilestoneModalViewControllerDelegate: AnyObject {
    func milestoneDidReach(_ milestone: GrowthMilestone, image: UIImage?, videoURL: URL?)
}

class MilestoneModalViewController: UIViewController {
    private let category: String
    private let milestoneTitle: String
    private let milestoneDescription: String
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let datePicker = UIDatePicker()
    private let reachedOnLabel = UILabel()
    private let imageView = UIImageView()
    private var videoURL: URL? = nil
    private var playerViewController: AVPlayerViewController?
    private let captionTextField = UITextField()
    private let addImageButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let cardView = UIView()
    private let secondSeperatorLine = UIView()
    private var cardViewHeightConstraint: NSLayoutConstraint?
    
    var milestone: GrowthMilestone?
    weak var delegate: MilestoneModalViewControllerDelegate?
    var baby: Baby?
    
    var onSave: ((Date, UIImage?, URL?, String?) -> Void)?
    
    init(category: String, title: String, description: String, milestone: GrowthMilestone) {
        self.category = category
        self.milestoneTitle = title
        self.milestoneDescription = description
        self.milestone = milestone
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    private func setupUI() {
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.backgroundColor = .systemGray6
        
//        let modalTitle = UILabel()
//        modalTitle.text = "Add \(category) Milestone"
//        modalTitle.font = .boldSystemFont(ofSize: 18)
//        modalTitle.textAlignment = .center
//        view.addSubview(modalTitle)
//        modalTitle.translatesAutoresizingMaskIntoConstraints = false
        let navigationBar = UINavigationBar()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        let navItem = UINavigationItem(title: "Add \(category) Milestone")

        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))

        navItem.leftBarButtonItem = cancelItem
        navItem.rightBarButtonItem = saveItem
        navigationBar.setItems([navItem], animated: false)

        view.addSubview(navigationBar)

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        titleLabel.text = milestoneTitle
        titleLabel.font = .systemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.text = milestoneDescription
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .gray
        view.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.layer.cornerRadius = 8
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.backgroundColor = .white
        cardView.isUserInteractionEnabled = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardViewHeightConstraint = cardView.heightAnchor.constraint(equalToConstant: 100)
        cardViewHeightConstraint?.isActive = true
        view.addSubview(cardView)
        
        reachedOnLabel.text = "Reached on"
        reachedOnLabel.font = .systemFont(ofSize: 16)
        reachedOnLabel.textAlignment = .left
        cardView.addSubview(reachedOnLabel)
        reachedOnLabel.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        cardView.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        let firstSeperatorLine = UIView()
        firstSeperatorLine.backgroundColor = .lightGray
        cardView.addSubview(firstSeperatorLine)
        firstSeperatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        let specialMomentLabel = UILabel()
        specialMomentLabel.text = "Add Special Moment"
        specialMomentLabel.font = .systemFont(ofSize: 16)
        specialMomentLabel.textAlignment = .left
        cardView.addSubview(specialMomentLabel)
        specialMomentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        addImageButton.setImage(UIImage(systemName: "photo.badge.plus"), for: .normal)
        addImageButton.tintColor = .systemBlue
        cardView.addSubview(addImageButton)
        addImageButton.translatesAutoresizingMaskIntoConstraints = false
        
        secondSeperatorLine.backgroundColor = .lightGray
        secondSeperatorLine.isHidden = true
        cardView.addSubview(secondSeperatorLine)
        secondSeperatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        captionTextField.placeholder = "Add a caption..."
        captionTextField.borderStyle = .none
        captionTextField.isHidden = true
        captionTextField.isUserInteractionEnabled = true
        captionTextField.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTextFieldTap))
        captionTextField.addGestureRecognizer(tapGesture)
//        print(captionTextField.frame)
        cardView.addSubview(captionTextField)
        
        imageView.contentMode = .scaleToFill
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.cornerRadius = 8
        imageView.isHidden = true
        cardView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            cardView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            reachedOnLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            reachedOnLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            reachedOnLabel.centerYAnchor.constraint(equalTo: datePicker.centerYAnchor),
            
            datePicker.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            firstSeperatorLine.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 50),
            firstSeperatorLine.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            firstSeperatorLine.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            firstSeperatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            specialMomentLabel.centerYAnchor.constraint(equalTo: addImageButton.centerYAnchor),
            specialMomentLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
//            specialMomentLabel.bottomAnchor.constraint(equalTo: secondSeperatorLine.bottomAnchor, constant: -8),
            
            addImageButton.topAnchor.constraint(equalTo: firstSeperatorLine.bottomAnchor, constant: 12),
            addImageButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            addImageButton.centerYAnchor.constraint(equalTo: specialMomentLabel.centerYAnchor),
            
            secondSeperatorLine.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -50),
            secondSeperatorLine.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            secondSeperatorLine.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            secondSeperatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            imageView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 10),
            imageView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            captionTextField.topAnchor.constraint(equalTo: secondSeperatorLine.bottomAnchor, constant: 5),
            captionTextField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            captionTextField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            captionTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    @objc func handleTextFieldTap() {
//        print("Caption TextField tapped!")
    }
    @objc private func selectImage() {
        let alertController = UIAlertController(title: "Choose Media Source", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Take a Photo", style: .default) { _ in
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }
            alertController.addAction(cameraAction)
            let videoAction = UIAlertAction(title: "Take a Video", style: .default) { _ in
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.mediaTypes = ["public.movie"]
                picker.videoQuality = .typeMedium
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }
            alertController.addAction(videoAction)
        }
        let photoLibraryAction = UIAlertAction(title: "Choose from Library", style: .default) { _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.mediaTypes = ["public.image", "public.movie"]
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
        alertController.addAction(photoLibraryAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func saveTapped() {
        guard let milestone = milestone else { return }

        let selectedImage = imageView.image
        let selectedVideoURL = videoURL
        let caption = captionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        if (selectedImage != nil || selectedVideoURL != nil) && (caption?.isEmpty ?? true) {
            let confirmAlert = UIAlertController(
                title: "Add Caption?",
                message: "You haven't added a caption. Do you want to save without a caption?",
                preferredStyle: .alert
            )

            confirmAlert.addAction(UIAlertAction(title: "Save Anyway", style: .default) { _ in
                self.onSave?(self.datePicker.date, selectedImage, selectedVideoURL, nil)
                self.delegate?.milestoneDidReach(milestone, image: selectedImage, videoURL: selectedVideoURL)
                self.dismiss(animated: true, completion: nil)
            })

            confirmAlert.addAction(UIAlertAction(title: "Add Caption", style: .cancel, handler: nil))
            present(confirmAlert, animated: true, completion: nil)
        } else {
            onSave?(datePicker.date, selectedImage, selectedVideoURL, caption)
            delegate?.milestoneDidReach(milestone, image: selectedImage, videoURL: selectedVideoURL)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension MilestoneModalViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            // Image selected
            imageView.image = selectedImage
            imageView.isHidden = false
            captionTextField.isHidden = false
            videoURL = nil
            playerViewController?.view.removeFromSuperview()
            
            cardViewHeightConstraint?.constant = 150
            secondSeperatorLine.isHidden = false
        } else if let videoURL = info[.mediaURL] as? URL {
            self.videoURL = videoURL
            imageView.isHidden = true
            playerViewController?.view.removeFromSuperview()
            
            let player = AVPlayer(url: videoURL)
            let playerVC = AVPlayerViewController()
            playerVC.player = player
            playerVC.view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(playerVC.view)
            NSLayoutConstraint.activate([
                playerVC.view.topAnchor.constraint(equalTo: imageView.topAnchor),
                playerVC.view.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                playerVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                playerVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                playerVC.view.heightAnchor.constraint(equalToConstant: 300)
            ])
            
            self.addChild(playerVC)
            playerVC.didMove(toParent: self)
            self.playerViewController = playerVC
            captionTextField.isHidden = false
            cardViewHeightConstraint?.constant = 150
            secondSeperatorLine.isHidden = false
        } else {
            imageView.isHidden = true
            playerViewController?.view.removeFromSuperview()
            videoURL = nil
            captionTextField.isHidden = true
            
            cardViewHeightConstraint?.constant = 100
            secondSeperatorLine.isHidden = true
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        picker.dismiss(animated: true)
    }
}
