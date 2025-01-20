import UIKit

protocol MilestoneModalViewControllerDelegate: AnyObject {
    func milestoneDidReach(_ milestone: GrowthMilestone)
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
    private let addImageButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    
    weak var delegate: MilestoneModalViewControllerDelegate?
    
    var onSave: ((Date, UIImage?) -> Void)?
    
    init(category: String, title: String, description: String) {
        self.category = category
        self.milestoneTitle = title
        self.milestoneDescription = description
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
        
        let modalTitle = UILabel()
        modalTitle.text = "Add \(category) Milestone"
        modalTitle.font = .boldSystemFont(ofSize: 18)
        modalTitle.textAlignment = .center
        view.addSubview(modalTitle)
        modalTitle.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = milestoneTitle
        titleLabel.font = .systemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.text = milestoneDescription
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        view.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let cardView = UIView()
        cardView.layer.cornerRadius = 8
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.backgroundColor = .white
        view.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        reachedOnLabel.text = "Reached on"
        reachedOnLabel.font = .systemFont(ofSize: 16)
        reachedOnLabel.textAlignment = .left
        cardView.addSubview(reachedOnLabel)
        reachedOnLabel.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.datePickerMode = .date
        cardView.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = .lightGray
        cardView.addSubview(separatorLine)
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        imageView.contentMode = .scaleToFill
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.cornerRadius = 8
        imageView.isHidden = true
        cardView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            modalTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            modalTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: modalTitle.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            cardView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cardView.heightAnchor.constraint(equalToConstant: 102),
            
            reachedOnLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            reachedOnLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            reachedOnLabel.centerYAnchor.constraint(equalTo: datePicker.centerYAnchor),
            
            datePicker.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            separatorLine.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 8),
            separatorLine.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            separatorLine.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            specialMomentLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 8),
            specialMomentLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            
            addImageButton.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 8),
            addImageButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            addImageButton.centerYAnchor.constraint(equalTo: specialMomentLabel.centerYAnchor),
            
            imageView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            imageView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            saveButton.centerYAnchor.constraint(equalTo: modalTitle.centerYAnchor),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            cancelButton.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor)
        ])
    }
    
    @objc private func selectImage() {
        let alertController = UIAlertController(title: "Choose Photo Source", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Take a Photo", style: .default) { _ in
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }
            alertController.addAction(cameraAction)
        }
        
        let photoLibraryAction = UIAlertAction(title: "Choose from Library", style: .default) { _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
        alertController.addAction(photoLibraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func saveTapped() {
        onSave?(datePicker.date, imageView.image)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension MilestoneModalViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
            imageView.isHidden = false
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
